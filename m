From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net v2 3/7] net: cpmac: dynamic debug fixes
Date: Thu, 10 Jul 2014 02:03:34 -0700
Message-ID: <1404983014.8839.8.camel@joe-AO725>
References: <1404970545-26508-1-git-send-email-varkabhadram@gmail.com>
	 <1404970545-26508-4-git-send-email-varkabhadram@gmail.com>
	 <1404981109.8839.6.camel@joe-AO725> <53BE52B7.40107@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mugunthanvnm@ti.com,
	linux@rainbow-software.org, balbi@ti.com, george.cherian@ti.com,
	davem@davemloft.net, Varka Bhadram <varkab@cdac.in>
To: Varka Bhadram <varkabhadram@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0002.hostedemail.com ([216.40.44.2]:38055 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752600AbaGJJDj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 05:03:39 -0400
In-Reply-To: <53BE52B7.40107@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-07-10 at 14:15 +0530, Varka Bhadram wrote:
> Hi,

Hello.

> This series already applied to net-next by David Miller.

You could improve it anyway.

> Anyway we will discuss this. If change required i will send the patch
> 
> On 07/10/2014 02:01 PM, Joe Perches wrote:
> > On Thu, 2014-07-10 at 11:05 +0530, varkabhadram@gmail.com wrote:
> >> From: Varka Bhadram <varkab@cdac.in>
> >>
> >> This patch does the following changes
> >> 1. convert printk(KERN_DEBUG.. to netdev_dbg() if we have net_device object
> >>     or convert to dev_dbg() if we have device object.
> > []
> >> diff --git a/drivers/net/ethernet/ti/cpmac.c b/drivers/net/ethernet/ti/cpmac.c
> > []
> >> @@ -228,21 +228,20 @@ static void cpmac_dump_regs(struct net_device *dev)
> >>   		if (i % 16 == 0) {
> >>   			if (i)
> >>   				pr_cont("\n");
> >> -			printk(KERN_DEBUG "%s: reg[%p]:", dev->name,
> >> -			       priv->regs + i);
> >> +			netdev_dbg(dev, "reg[%p]:", priv->regs + i);
> >>   		}
> >> -		printk(" %08x", cpmac_read(priv->regs, i));
> >> +		pr_debug(" %08x", cpmac_read(priv->regs, i));
> 
> You mean to say that the pr_debug will insert the new line ?... I dont think so..

Try it.

If you're using dynamic_debug, remember to
enable all the lines.
