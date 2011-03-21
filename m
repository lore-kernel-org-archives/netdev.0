From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: Re: LRO disable warnings on kernel 2.6.38
Date: Mon, 21 Mar 2011 11:27:25 +0100
Message-ID: <1300703245.10934.75.camel@firesoul.comx.local>
References: <1300446743.11985.317.camel@firesoul.comx.local>
	 <4D8385CE.1060205@intel.com>
	 <1300699294.10934.63.camel@firesoul.comx.local>
	 <1300700708.2884.10.camel@edumazet-laptop>
	 <1300701232.2884.12.camel@edumazet-laptop>
	 <1300701852.10934.67.camel@firesoul.comx.local>
	 <1300702282.2884.23.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev <netdev@vger.kernel.org>,
	Neil Horman <nhorman@tuxdriver.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:33424 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752443Ab1CUK11 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2011 06:27:27 -0400
In-Reply-To: <1300702282.2884.23.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-03-21 at 11:11 +0100, Eric Dumazet wrote:
> Sure, this is the problem. Still your ethtool dont give us the needed
> info ;)
> 
> I suspect it is :
> 
> rx-vlan-offload: off
> tx-vlan-offload: on

albpd4:~# ~/ethtool-2.6.38 -k eth01
Offload parameters for eth01:
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp-segmentation-offload: on
udp-fragmentation-offload: off
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: on
rx-vlan-offload: off
tx-vlan-offload: on
ntuple-filters: off
receive-hashing: off

> But would like a confirmation of this ;)

Bonus! - with a newer version of ethtool ;-0

> # ethtool -V | head -n 1
> ethtool version 2.6.37

albpd4:~# ethtool -V | head -1
ethtool version 2.6.34

> # ethtool --version
> ethtool version 2.6.37

albpd4:~# ~/ethtool-2.6.38 --version
ethtool version 2.6.38
(actually latest git tree, 423c656b22ec which is a release by Ben)


-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network Kernel Developer
  Cand. Scient Datalog / MSc.CS
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer


