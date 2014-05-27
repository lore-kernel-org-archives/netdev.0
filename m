From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: net: export TSO helper functions
Date: Tue, 27 May 2014 14:52:49 +0200
Message-ID: <6987021.dP2tJ87JXR@wuerfel>
References: <4514086.6xHrns0u2W@wuerfel> <20140527123747.GB1655@arch.cereza>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	sachin.kamat@linaro.org
To: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.130]:58912 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751779AbaE0Mwy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2014 08:52:54 -0400
In-Reply-To: <20140527123747.GB1655@arch.cereza>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 27 May 2014 09:37:47 Ezequiel Garcia wrote:
> On 27 May 12:16 PM, Arnd Bergmann wrote:
> > The software TSO helper API was recently added but so far only
> > works for built-in device drivers. This adds appropriate exports
> > to let us build the drivers using it as loadable modules.
> > 
> 
> Thanks for the patch. Another similar fix was sent recently:
> 
> http://patchwork.ozlabs.org/patch/352452/

Ah, I missed that.
 
> which proposes to use EXPORT_SYMBOL, instead of EXPORT_SYMBOL_GPL. Being a core
> API, I think the former is more appropriate, so I'd rather pick it instead of
> this one.

I use _GPL out of principle for any new code, but it's not important to
me here, as long as one of the patches gets applied.

	Arnd
