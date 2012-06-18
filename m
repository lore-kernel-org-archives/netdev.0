From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: unstable 10GBE performance with recent kernels (> 3.0.X)
Date: Mon, 18 Jun 2012 11:45:06 +0200
Message-ID: <1340012706.7491.770.camel@edumazet-glaptop>
References: <4FDEF34C.808@profihost.ag>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:60846 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752426Ab2FRJpK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2012 05:45:10 -0400
Received: by eeit10 with SMTP id t10so1483149eei.19
        for <netdev@vger.kernel.org>; Mon, 18 Jun 2012 02:45:09 -0700 (PDT)
In-Reply-To: <4FDEF34C.808@profihost.ag>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-06-18 at 11:22 +0200, Stefan Priebe - Profihost AG wrote:
> Hello list,
> 
> i've discovered very unstable 10GBE performance using recent kernels. 
> I'm using some optimized settings mentioned by intel here 
> (part:Improving Performance): 
> http://downloadmirror.intel.com/5874/eng/README.txt
> 

like what settings ?

> I'm using Intel X520 cards (ixgbe driver version: 3.9.17-NAPI in all 
> tests).
> 
> I'm measuring the performance with iperf.
> 
> With 3.0.32 i get constant 9,90 Gbit/s in both directions simultaneously.
> 
> With 3.4.2 or 3.5.0-rc2 it get sometimes 9,9gbit/s - sometimes 3gbit/s 
> or even sometimes only 1gbit/s throughput.
> 
> I also tried to change the tcp_congestion_control from cubic to reno, 
> bic and highspeed but no change.
> 
> I also tried to bisect the issue but there are so many changes in the 
> net kernel part that i'm unable to identify the problem as with some 
> commits i only get 0-300kb/s performance.
> 
> Any ideas?

ethtool -S eth0
ethtool -k eth0
netstat -s   (on sender, on receiver)

single flow , multiple flows ?
