From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net] r8169:Remove unnecessary phy reset for pcie nic when
 setting link spped.
Date: Wed, 9 Mar 2016 22:44:26 +0100
Message-ID: <20160309214425.GA9533@electric-eye.fr.zoreil.com>
References: <1457427065-3699-1-git-send-email-hau@realtek.com>
 <20160308234855.GA6182@electric-eye.fr.zoreil.com>
 <80377ECBC5453840BA8C7155328B53770137C08D@RTITMBSV03.realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	nic_swsd <nic_swsd@realtek.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Hau <hau@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:33425 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750819AbcCIVoe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 16:44:34 -0500
Content-Disposition: inline
In-Reply-To: <80377ECBC5453840BA8C7155328B53770137C08D@RTITMBSV03.realtek.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hau <hau@realtek.com> :
[...] 
> Unless pcie nic has bug, pcie nic does not need to reset phy to let phy link on.
> 
> There is a counter for phy speed down. If phy is in link down state, this
> counter will start to count down. When it count to 0, phy will speed down.
> Reset phy will reset this counter and prevent phy from speed down.

Thanks for the clarification.

-- 
Ueimor
