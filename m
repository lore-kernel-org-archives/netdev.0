From: Samir Bellabes <sbellabes@mandriva.com>
Subject: Re: [2.6.18 backport] RTL8168 ethernet support in r8169
Date: Fri, 29 Sep 2006 04:46:48 +0200
Message-ID: <m264f7jso7.fsf@cerbere.dyndns.info>
References: <451972B0.5020805@gentoo.org>
	<20060926191458.GB15039@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Drake <dsd@gentoo.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 188.235.97-84.rev.gaoland.net ([84.97.235.188]:8939 "EHLO
	cerbere.dyndns.info") by vger.kernel.org with ESMTP
	id S1751324AbWI2Cru (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 22:47:50 -0400
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20060926191458.GB15039@electric-eye.fr.zoreil.com> (Francois
	Romieu's message of "Tue, 26 Sep 2006 21:14:58 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu <romieu@fr.zoreil.com> writes:

> Daniel Drake <dsd@gentoo.org> :
> [...]
>  static struct pci_device_id rtl8169_pci_tbl[] = {
> -	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8169), },
> -	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8129), },
> -	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK,	0x4300), },
> -	{ PCI_DEVICE(0x16ec,			0x0116), },
> -	{ PCI_VENDOR_ID_LINKSYS,		0x1032, PCI_ANY_ID, 0x0024, },
> +	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8129), 0, 0, RTL_CFG_0 },
> +	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8136), 0, 0, RTL_CFG_1 },
>
> Should be RTL_CFG_2 (but there are still issues with the link management).
>
> +	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8167), 0, 0, RTL_CFG_1 },
>                                                                ^^^^^^^^^
> Should be RTL_CFG_1.

You mean should be RTL_CFG_0 ?

> Is there any chance that you can push a different patch for your releases ?
>
> There are no pending changes outside of the git vanilla tree. As an option,
> you can use the patch below too:
> http://www.fr.zoreil.com/people/francois/misc/20060920-2.6.18-r8169-test.patch

I have backported this pointed patch to 2.6.17. [1]
So far, it have been tested successfully with this devices:
RTL-8169
RTL-8169SC
RTL-8168

[1] http://cvs.mandriva.com/cgi-bin/viewvc.cgi/packages/cooker/kernel-2.6/current/PATCHES/patches/DN85_r8169_others.patch?root=svn&view=log

regards,

-- 
Samir Bellabes
Mandriva
