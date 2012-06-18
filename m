From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: unstable 10GBE performance with recent kernels (> 3.0.X)
Date: Mon, 18 Jun 2012 15:29:04 +0200
Message-ID: <1340026144.7491.1231.camel@edumazet-glaptop>
References: <4FDEF34C.808@profihost.ag>
	 <1340012706.7491.770.camel@edumazet-glaptop>
	 <4FDEFD55.7010204@profihost.ag>
	 <1340015143.7491.855.camel@edumazet-glaptop>
	 <4FDF20B2.2010603@profihost.ag>
	 <1340023876.7491.1153.camel@edumazet-glaptop>
	 <4FDF2829.6050705@profihost.ag>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:53994 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752033Ab2FRN3J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2012 09:29:09 -0400
Received: by eeit10 with SMTP id t10so1569108eei.19
        for <netdev@vger.kernel.org>; Mon, 18 Jun 2012 06:29:08 -0700 (PDT)
In-Reply-To: <4FDF2829.6050705@profihost.ag>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-06-18 at 15:07 +0200, Stefan Priebe - Profihost AG wrote:
> Am 18.06.2012 14:51, schrieb Eric Dumazet:
>  > On Mon, 2012-06-18 at 14:36 +0200, Stefan Priebe - Profihost AG wrote:
>  >> Am 18.06.2012 12:25, schrieb Eric Dumazet:
>  >>> I would remove all this (pretty old and obsolete) stuff and use 
> standard
>  >>> params.
>  >> OK, thanks. done.
>  >>
>  >> I've one RHEL6 system (using default 2.6.32 kernel) where only using
>  >> "ntuple on" results in just 4-5Gbit/s while the others using 3.5.0-rc2
>  >> are working fine.
>  >>
>  >
>  > OK, then you might play with affinities, that's the only thing that
>  > might need sysadmin tuning (irqbalance needs to be disabled)
> 
> I've now used this one:
> 
> # script provided by intel
> /root/set_irq_affinity.sh eth2
> ifconfig eth2 mtu 9000
> ethtool -K eth2 ntuple on
> 
> irqbalance is off
> 
> But with the latest long term stable vanilla kernel 3.0.34.
> 
> # iperf -c HOST -t 60
> 
> works fine but with -d for using both directions i see around 9.8Gbit/s 
> in one direction and only 300kb/s in the other direction.
> 
> Stefan


I would try using regular MTU.

And post "netstat -s" results before/after your iperf.
