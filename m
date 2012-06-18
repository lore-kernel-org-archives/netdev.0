From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Subject: Re: unstable 10GBE performance with recent kernels (> 3.0.X)
Date: Mon, 18 Jun 2012 14:36:02 +0200
Message-ID: <4FDF20B2.2010603@profihost.ag>
References: <4FDEF34C.808@profihost.ag>  <1340012706.7491.770.camel@edumazet-glaptop>  <4FDEFD55.7010204@profihost.ag> <1340015143.7491.855.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.profihost.ag ([85.158.179.208]:56867 "EHLO
	mail.profihost.ag" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751042Ab2FRMgE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2012 08:36:04 -0400
In-Reply-To: <1340015143.7491.855.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 18.06.2012 12:25, schrieb Eric Dumazet:
> I would remove all this (pretty old and obsolete) stuff and use standard
> params.
OK, thanks. done.

I've one RHEL6 system (using default 2.6.32 kernel) where only using 
"ntuple on" results in just 4-5Gbit/s while the others using 3.5.0-rc2 
are working fine.

> Only thing you could do is :
> ethtool -K eth2 ntuple on
>
> on both machines
Thanks that works great and boosts the performance a lot. What does it 
do? man ethtool doesn't show anything useful.

Is this also recommanded for 1Gb/s?

Could you recommend a tcp_congestion_control module? RHEL6 uses cubic by 
default. Some others use reno or bic.

Stefan
