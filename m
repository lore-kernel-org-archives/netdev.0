From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] don't allow / in class device names
Date: Fri, 13 Feb 2004 12:45:55 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040213124555.00cbf3d7@dell_ss3.pdx.osdl.net>
References: <20040213102755.27cf4fcd.shemminger@osdl.org>
	<20040213203448.GB14048@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Tommi Virtanen <tv@tv.debian.net>, Leann Ogasawara <ogasawara@osdl.org>,
        netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Greg KH <greg@kroah.com>
In-Reply-To: <20040213203448.GB14048@kroah.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> No, the "fix" is to just not do this in the driver.  I'm not going to
> apply this patch, sorry.
> 
> thanks,
> 
> greg k-h

Bah, kernel API's should check there arguments.  One of my peeve's about sysfs is
that it is far too lazy about checking it's inputs.  Especially, when the restrictions
are not well documented, the code needs to validate.
