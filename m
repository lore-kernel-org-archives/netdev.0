From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Subject: Re: unstable 10GBE performance with recent kernels (> 3.0.X)
Date: Mon, 18 Jun 2012 15:07:53 +0200
Message-ID: <4FDF2829.6050705@profihost.ag>
References: <4FDEF34C.808@profihost.ag>  <1340012706.7491.770.camel@edumazet-glaptop>  <4FDEFD55.7010204@profihost.ag>  <1340015143.7491.855.camel@edumazet-glaptop>  <4FDF20B2.2010603@profihost.ag> <1340023876.7491.1153.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.profihost.ag ([85.158.179.208]:51521 "EHLO
	mail.profihost.ag" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750828Ab2FRNHz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2012 09:07:55 -0400
In-Reply-To: <1340023876.7491.1153.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 18.06.2012 14:51, schrieb Eric Dumazet:
 > On Mon, 2012-06-18 at 14:36 +0200, Stefan Priebe - Profihost AG wrote:
 >> Am 18.06.2012 12:25, schrieb Eric Dumazet:
 >>> I would remove all this (pretty old and obsolete) stuff and use 
standard
 >>> params.
 >> OK, thanks. done.
 >>
 >> I've one RHEL6 system (using default 2.6.32 kernel) where only using
 >> "ntuple on" results in just 4-5Gbit/s while the others using 3.5.0-rc2
 >> are working fine.
 >>
 >
 > OK, then you might play with affinities, that's the only thing that
 > might need sysadmin tuning (irqbalance needs to be disabled)

I've now used this one:

# script provided by intel
/root/set_irq_affinity.sh eth2
ifconfig eth2 mtu 9000
ethtool -K eth2 ntuple on

irqbalance is off

But with the latest long term stable vanilla kernel 3.0.34.

# iperf -c HOST -t 60

works fine but with -d for using both directions i see around 9.8Gbit/s 
in one direction and only 300kb/s in the other direction.

Stefan
