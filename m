From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: packetloss, on e1000e worse than r8169?
Date: Mon, 16 Jun 2008 23:05:09 +0200
Message-ID: <4856D585.5070602@cosmosbay.com>
References: <20080616193501.M64730@visp.net.lb> <4856C3A7.9070703@cosmosbay.com> <20080616202210.M84100@visp.net.lb> <4856CEDC.6010706@intel.com> <20080616204411.M52834@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
	format=flowed
Content-Transfer-Encoding: 7BIT
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>, netdev@vger.kernel.org,
	linux.nics@intel.com
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2a.orange.fr ([80.12.242.140]:20399 "EHLO smtp2a.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755050AbYFPVFk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 17:05:40 -0400
In-Reply-To: <20080616204411.M52834@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryshchenko a e'crit :
> [    0.241017] IP route cache hash table entries: 32768 (order: 5, 131072 bytes)
> [    6.337111] nf_conntrack version 0.5.0 (16384 buckets, 65536 max)

Are you sure nf_conntrack or ip route cache is not killing you ?

Filling 512 or 1024 RX ring on Gigabit link can be very fast, especially 
if ip route cache is full.

rtstat -c10 -i1



