From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: ipg and dl2k mess
Date: Sat, 22 Aug 2015 13:25:54 +0200
Message-ID: <20150822112554.GC24519@electric-eye.fr.zoreil.com>
References: <201508212224.00090.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Kernel development list <linux-kernel@vger.kernel.org>,
	Sorbica Shieh <sorbica@icplus.com.tw>
To: Ondrej Zary <linux@rainbow-software.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:55312 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752426AbbHVL0b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Aug 2015 07:26:31 -0400
Content-Disposition: inline
In-Reply-To: <201508212224.00090.linux@rainbow-software.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ondrej Zary <linux@rainbow-software.org> :
[...]
> The patch below is enough to make my IP1000A card work with dl2k driver - no
> more lost packets and hangs. Haven't tested gigabit speed yet - the PHY will
> probably need some tweaking but that should be easy.

Neither dl2k nor ipg uses napi. They are a bit dusty.

> So maybe we should add IP1000A support to dl2k and remove the broken ipg
> driver.

Do you mean to merge both ?

> Does anyone have HW to test?

I have a PCI 32 IC Plus IP1000A at hand (courtesy of IC Plus Corp).

-- 
Ueimor
