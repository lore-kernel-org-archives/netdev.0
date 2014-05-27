From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: Re: net: export TSO helper functions
Date: Tue, 27 May 2014 09:37:47 -0300
Message-ID: <20140527123747.GB1655@arch.cereza>
References: <4514086.6xHrns0u2W@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	sachin.kamat@linaro.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:38084 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751960AbaE0MiZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2014 08:38:25 -0400
Content-Disposition: inline
In-Reply-To: <4514086.6xHrns0u2W@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Arnd,

On 27 May 12:16 PM, Arnd Bergmann wrote:
> The software TSO helper API was recently added but so far only
> works for built-in device drivers. This adds appropriate exports
> to let us build the drivers using it as loadable modules.
>=20

Thanks for the patch. Another similar fix was sent recently:

http://patchwork.ozlabs.org/patch/352452/

which proposes to use EXPORT_SYMBOL, instead of EXPORT_SYMBOL_GPL. Bein=
g a core
API, I think the former is more appropriate, so I'd rather pick it inst=
ead of
this one.
--=20
Ezequiel Garc=EDa, Free Electrons
Embedded Linux, Kernel and Android Engineering
http://free-electrons.com
