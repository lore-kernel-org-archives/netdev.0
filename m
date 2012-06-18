From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Subject: unstable 10GBE performance with recent kernels (> 3.0.X)
Date: Mon, 18 Jun 2012 11:22:20 +0200
Message-ID: <4FDEF34C.808@profihost.ag>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.profihost.ag ([85.158.179.208]:60026 "EHLO
	mail.profihost.ag" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754892Ab2FRJ3D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2012 05:29:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello list,

i've discovered very unstable 10GBE performance using recent kernels. 
I'm using some optimized settings mentioned by intel here 
(part:Improving Performance): 
http://downloadmirror.intel.com/5874/eng/README.txt

I'm using Intel X520 cards (ixgbe driver version: 3.9.17-NAPI in all 
tests).

I'm measuring the performance with iperf.

With 3.0.32 i get constant 9,90 Gbit/s in both directions simultaneously.

With 3.4.2 or 3.5.0-rc2 it get sometimes 9,9gbit/s - sometimes 3gbit/s 
or even sometimes only 1gbit/s throughput.

I also tried to change the tcp_congestion_control from cubic to reno, 
bic and highspeed but no change.

I also tried to bisect the issue but there are so many changes in the 
net kernel part that i'm unable to identify the problem as with some 
commits i only get 0-300kb/s performance.

Any ideas?

Greets
Stefan
