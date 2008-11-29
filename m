From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Realtek 8169 problems with net booting
Date: Sat, 29 Nov 2008 22:28:30 +0100
Message-ID: <20081129212830.GA5846@electric-eye.fr.zoreil.com>
References: <20081124181456.66a967d2@lxorguk.ukuu.org.uk> <20081129204416.GA6401@electric-eye.fr.zoreil.com> <20081129210600.GT28946@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, netdev@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:35458 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752343AbYK2V2y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Nov 2008 16:28:54 -0500
Content-Disposition: inline
In-Reply-To: <20081129210600.GT28946@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Al Viro <viro@ZenIV.linux.org.uk> :
[...]
> Other symptoms: it kept trying to renegotiate the link every few seconds.

[...]
> Hang used to happen on the first incoming packet after boot, _but_ that
> didn't happen on each boot.

Ok, it is consistent with a dma at (more or less) random location.

Thanks for the report Al.

Can you send the "XID" line printed by the driver on recent kernels so
that I can figure the specific version of the chipset / PHY ?

Do not hurry, I am out for saturday's night.

-- 
Ueimor
