From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Pull request for 'ipg' branch
Date: Wed, 5 Dec 2007 22:51:57 +0100
Message-ID: <20071205215157.GA3665@electric-eye.fr.zoreil.com>
References: <20071204214551.GA6345@electric-eye.fr.zoreil.com> <1196806495.10819.16.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, Pekka Enberg <penberg@cs.helsinki.fi>,
	Sorbica Shieh <sorbica@icplus.com.tw>,
	Jesse Huang <jesse@icplus.com.tw>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:57207 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751897AbXLEV6H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 16:58:07 -0500
Content-Disposition: inline
In-Reply-To: <1196806495.10819.16.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Perches <joe@perches.com> :
[...]
> > -	if ((sp->LED_Mode & 0x01) == 1)
> > +	if ((sp->led_mode & 0x01) == 1)
> 
> I think the use of hex and decimal constants is odd.
> I think "if (sp->led_mode & 0x01)" is better.

Yes, the whole context of this code in the driver is a bit special.

[...]
> >  /* Assign IPG_APPEND_FCS_ON_TX > 0 for auto FCS append on TX. */
> > -#define         IPG_APPEND_FCS_ON_TX         TRUE
> > +#define         IPG_APPEND_FCS_ON_TX         1
> 
> Why not true and false?

No objection. Both can be used.

[...]
> > @@ -753,8 +732,7 @@ enum ipg_regs {
> >   * Miscellaneous macros.
> >   */
> >  
> > -/* Marco for printing debug statements.
> > -#  define IPG_DDEBUG_MSG(args...) printk(KERN_DEBUG "IPG: " ## args) */
> > +/* Marco for printing debug statements. */
> 
> Macros

I actively ignored it. It was not easy. :o)

-- 
Ueimor
