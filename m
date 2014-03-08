From: Steffen Trumtrar <s.trumtrar@pengutronix.de>
Subject: Re: [PATCH] ath6kl: sdio: fix system panic when doing wifi stress
 test
Date: Sat, 8 Mar 2014 16:37:30 +0100
Message-ID: <20140308153730.GA27506@pengutronix.de>
References: <1384221185-8645-1-git-send-email-r64343@freescale.com>
 <87k3fvjvjg.fsf@kamboji.qca.qualcomm.com>
 <AD13664F485EE54694E29A7F9D5BE1AFC0AD96@039-SN2MPN1-022.039d.mgd.msft.net>
 <20140307093813.GA28728@pengutronix.de>
 <87a9d0oqbz.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hui Liu <Hui.Liu@freescale.com>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linville@tuxdriver.com" <linville@tuxdriver.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	ath6kl@lists.infradead.org
To: Kalle Valo <kvalo@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:42020 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751590AbaCHPhi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Mar 2014 10:37:38 -0500
Content-Disposition: inline
In-Reply-To: <87a9d0oqbz.fsf@kamboji.qca.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 08, 2014 at 01:57:36PM +0200, Kalle Valo wrote:
> Hi Steffen,
> 
> Steffen Trumtrar <s.trumtrar@pengutronix.de> writes:
> 
> >> > Does the patch below help? It would also fix the corruption with
> >> > scat_q_depth. Please note that I have only compile tested it. And I might
> >> > have also missed something important, so please review it carefully.
> >> 
> >> Yes, Firstly, I have looked at the asm code and the compiler(gcc 4.8.1) works correctly after applying
> >> the following patch. Secondly, I have tested the patch with compiler(gcc 4.8.1) on the real HW, and it
> >> works fine too. Without the patch, the kernel crash will happen 100%.
> >> 
> >> Thus, for the patch:
> >> 
> >> Acked-by: Jason Liu <r64343@freescale.com>
> >> Tested-by: Jason Liu <r64343@freescale.com>
> 
> [...]
> 
> > What happend with this? If I look in mainline, I don't find it. At
> > least the reording of the struct fields looks as if one definitely
> > wants to have that.
> 
> It seems that I forgot to submit this properly, sorry about that. I did
> it now:
> 
> http://lists.infradead.org/pipermail/ath6kl/2014-March/000000.html
> 

\o/ Thank you.

Regards,

Steffen

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
