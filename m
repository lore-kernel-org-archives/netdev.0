From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] isdn/eicon: do integrity check on cmd->adapter ==
 a->controller early
Date: Thu, 28 Sep 2017 09:32:20 -0700 (PDT)
Message-ID: <20170928.093220.2223492078191370005.davem@davemloft.net>
References: <1506266081-22895-1-git-send-email-mengxu.gatech@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mac@melware.de, isdn@linux-pingi.de, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, meng.xu@gatech.edu,
        sanidhya@gatech.edu, taesoo@gatech.edu
To: mengxu.gatech@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1506266081-22895-1-git-send-email-mengxu.gatech@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Meng Xu <mengxu.gatech@gmail.com>
Date: Sun, 24 Sep 2017 11:14:41 -0400

> +		/* do the integrity check early */
> +		if(((diva_xdi_um_cfg_cmd_t *)data)->adapter != a->controller){
> +			DBG_ERR(("A: A(%d) write, invalid controller=%d != %d",
> +						((diva_xdi_um_cfg_cmd_t *)data)->adapter, a->controller));
> +

DBG_ERR() has a trailing semicolon in it's definition, so if you add
another one when you invoke it there will be two ";;".

This whole code base is such a mess, I really think there is little
to no value in trying to make minor changes here.

So unless you are fixing some kind of exploitable hole, please drop
this.

Thank you.
