From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: [PATCH] Support for new rtl810x hardware
Date: Sun, 03 Aug 2008 22:22:17 +0200
Message-ID: <48961379.40606@redhat.com>
References: <4893986F.5090604@gmail.com> <CF18CE2CF7FD4328844F0749BE798A54@cera.cz> <20080802152049.GA10825@electric-eye.fr.zoreil.com> <20080802200241.GA20141@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	"'Xose Vazquez Perez'" <xose.vazquez@gmail.com>,
	Edward Hsu <edward_hsu@realtek.com.tw>, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:58952 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753004AbYHCUWv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Aug 2008 16:22:51 -0400
In-Reply-To: <20080802200241.GA20141@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Francois Romieu <romieu@fr.zoreil.com> :
> [...]
> 
> I have published a new serie at:
> 
> http://userweb.kernel.org/~romieu/r8169/2.6.27-rc1
> 
> It does not include the 8168 chipsets specific bits which are currently
> in the r8169 branch at git.kernel.org.
> 
> I'd appreciate if you could give the serie a try and tell me if it is
> ok to add your s-o-b to the patch below. It is synched with version
> 1.008.00 of Realtek 8101 driver (which exhibits some phy_config
> changes).
Yes, from my point of view it's OK.

> ...
> The 0x7c800000 mask is more or less reserved for the fallback,
> whence the introduction of the 0x34a00000 identifier.
Yes this is

> I have not understood under which basis you made a difference
> between 8102e and 8102el. As far as I can tell Realtek's driver
> does not disambiguate either: 0x34a00000 (resp. 0x34800000) and
> 0x24a00000 (resp. 0x24800000) both fall under CFG_METHOD_5
> (resp. CFG_METHOD_3). Did I miss something or was is more or
> less arbitrary ?
There was my mistake to use rtl8102e_hw_phy_config and
rtl8102el_hw_phy_config identifiers. But Realtek's driver v1.007.00
used different PHY configuration for CFG_METHOD_3 and for
CFG_METHOD_4/5. The current (v1.009.00) uses the common one for all
of them.

Regards,
Ivan
