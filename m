From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/3] geneve: Remote Checksum Offload support
Date: Tue, 08 Dec 2015 21:20:14 -0500 (EST)
Message-ID: <20151208.212014.293664653825079141.davem@davemloft.net>
References: <CALx6S36dU-RLUSTTZz8dVZHD7=p3=modbjUOePKMYG96FrA_zA@mail.gmail.com>
	<CAEh+42gMC7SSuSsJncxvFCeqJAGA4_DZs2qq3n1NRV7JHYu9SA@mail.gmail.com>
	<CALx6S37o+gQ4BLtphsDzbg-qPsiZo2_7TvhSdweLy8wAEbbjNw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesse@kernel.org, linville@tuxdriver.com, netdev@vger.kernel.org,
	jesse@nicira.com, kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47889 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752594AbbLICUQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 21:20:16 -0500
In-Reply-To: <CALx6S37o+gQ4BLtphsDzbg-qPsiZo2_7TvhSdweLy8wAEbbjNw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Tue, 8 Dec 2015 16:11:56 -0800

> I thought about a TLV implementation but there is no base support in
> the kernel for it. It would be great if you could implement the TLV
> loop. Honestly, though, I'm still very leery of the processing
> overhead associated with TLVs in the critical data path. In the
> worst case of RCO we would need to fish for the RCO option though
> the TLV list in both the GRO and normal path for each packet. If the
> TLV lists are long then performance may be negatively affected
> mitigating the value of RCO (needs to be measured).

Open ended TLVs are to me likened to an attack vector waiting to
happen, for the reasons Tom listed.
