From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Realtek r8168C / r8169 driver VLAN TAG stripping
Date: Thu, 27 Jan 2011 16:07:44 +0100
Message-ID: <20110127150744.GA7925@electric-eye.fr.zoreil.com>
References: <AANLkTi=qVSEh=RyzJ6y4kQvJW+hxqWMh2gAMmhk7GGob@mail.gmail.com> <AANLkTimqkJ3DGBX5iREEcx6sgAM+2CZHNWMU+noNSitp@mail.gmail.com> <20110116192017.GA3569@electric-eye.fr.zoreil.com> <AANLkTi=uNKMj_gs_bKRQ1tQa0TMwdnyrtVcR5JPNpmJv@mail.gmail.com> <AANLkTikoXfgHrJyMbe6A_HmvXT_QRo55w76st5Wo0hSv@mail.gmail.com> <20110118012146.GA3704@electric-eye.fr.zoreil.com> <AANLkTimA1C=trH+WGpBdPU=vBf-cN+xB4Br3+vJb-Qum@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Hayes <hayeswang@realtek.com>
To: Anand Raj Manickam <anandrm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:44725 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750904Ab1A0PJ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jan 2011 10:09:27 -0500
Content-Disposition: inline
In-Reply-To: <AANLkTimA1C=trH+WGpBdPU=vBf-cN+xB4Br3+vJb-Qum@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anand Raj Manickam <anandrm@gmail.com> :
[...]
> We upgraded to 2.6.36 kernel . The result is SAME.
> The VLAN tag gets stripped ;-)
> Do let me know if you need more info .

- ip addr show
- ethtool -k eth0

I do not get the "VLAN tag gets stripped" concept, especially on Tx.
Does it mean "no packet" or "a packet whose content is wrong" ?

-- 
Ueimor
