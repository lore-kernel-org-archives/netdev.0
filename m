From: Michael Guntsche <mike@it-loops.com>
Subject: Re: [BUG] 2.6.33-rc1 gianfar error message
Date: Mon, 21 Dec 2009 17:38:43 +0100
Message-ID: <20091221163843.GB3529@gibson.comsick.at>
References: <20091220214447.GA10233@trillian.comsick.at>
 <9F4C7D19E8361D4C94921B95BE08B81BA08F3B@zin33exm22.fsl.freescale.net>
 <20091221072704.GA12110@gibson.comsick.at>
 <9F4C7D19E8361D4C94921B95BE08B81BA08F83@zin33exm22.fsl.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Kumar Gopalpet-B05799 <B05799@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lvps87-230-0-242.dedicated.hosteurope.de ([87.230.0.242]:43344
	"EHLO lvps87-230-0-242.dedicated.hosteurope.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750779AbZLUQiu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Dec 2009 11:38:50 -0500
Content-Disposition: inline
In-Reply-To: <9F4C7D19E8361D4C94921B95BE08B81BA08F83@zin33exm22.fsl.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21 Dec 09 14:19, Kumar Gopalpet-B05799 wrote:
> Michael, 
> 
> Kindly try the following changes at your side and let me know the
> results. I couldn't test this
> as I don't have any TSEC device with me.
<snip>

Your patch did not apply to vanilla 2.6.32-rc1 at all. I patched the
code myself and up to now I do not see any error messages. Uptime is at
33 minutes, without the patch the error message appeared immediately
after booting.

Just for my understanding. Is the first diff part of the fix as well?
With this change the FCB is only removed if there are padded bytes, why
would this make a difference here?

Kind regards,
Michael
