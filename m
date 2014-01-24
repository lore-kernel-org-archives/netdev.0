From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 won't transmit with 3.12
Date: Fri, 24 Jan 2014 01:25:25 +0100
Message-ID: <20140124002525.GA29384@electric-eye.fr.zoreil.com>
References: <20140121000615.GA30495@enc.com.au>
 <20140121233630.GA3214@electric-eye.fr.zoreil.com>
 <20140122004119.GA28174@enc.com.au>
 <20140122233135.GA800@electric-eye.fr.zoreil.com>
 <20140123075708.GA9172@enc.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>,
	netdev@vger.kernel.org
To: Craig Small <csmall@enc.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:42867 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755473AbaAXAZj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 19:25:39 -0500
Content-Disposition: inline
In-Reply-To: <20140123075708.GA9172@enc.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Craig Small <csmall@enc.com.au> :
[...]
> That's fine. I was doing it to see if it would work. I'll stay with the r8169
> for now.

Thanks.

> I got a watchdog notice now, not sure if that is better or worse.

It's the usual Tx failure symptom.

[dmesg]
> [    0.000000] DMI: Gigabyte Technology Co., Ltd. To be filled by O.E.M./970A-D3P, BIOS F3 05/24/2013

(8168evl on a fairly recent motherboard, bios could be upgraded)

Did you enable the iommu in the setup ? If not, please give it a try.

-- 
Ueimor
