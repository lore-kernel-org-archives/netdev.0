From: Mitchell Blank Jr <mitch@sfgoth.com>
Subject: Re: [RFT][PATCH] cleanup net/atm/br2684.c
Date: Mon, 11 Aug 2003 14:58:57 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030811215857.GA96728@gaz.sfgoth.com>
References: <20030811114823.5b81474c.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chas williams <chas@cmf.nrl.navy.mil>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20030811114823.5b81474c.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

You might also want to send this patch to the linux-atm mailing list:
  linux-atm-general@lists.sourceforge.net
Unfortunately you need to subscribe to post.
  http://lists.sourceforge.net/lists/listinfo/linux-atm-general

Not sure how many ATM users are following 2.6 yet though.  I might be
able to give it a spin soon.

> -			unregister_netdev(&brdev->net_dev);
> -			kfree(brdev);
> +			unregister_netdev(brdev->net_dev);
> +			kfree(brdev->net_dev);

Mmmm.. I see this snippet in your diff in multiplce places and it looks
wrong.  Where does the "brdev" structure get freed now?

-Mitch
