From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Subject: Re: 10GBE performance drop with net.ipv4.tcp_timestamps=0
Date: Wed, 20 Jun 2012 11:06:41 +0200
Message-ID: <4FE192A1.6000000@profihost.ag>
References: <4FE0EA33.1000309@profihost.ag>  <1340141493.4604.773.camel@edumazet-glaptop>  <4FE17522.5050005@profihost.ag>  <1340176940.4604.801.camel@edumazet-glaptop>  <4FE1881B.7030800@profihost.ag> <1340181676.4604.838.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.profihost.ag ([85.158.179.208]:60374 "EHLO
	mail.profihost.ag" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754709Ab2FTJGr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2012 05:06:47 -0400
In-Reply-To: <1340181676.4604.838.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 20.06.2012 10:41, schrieb Eric Dumazet:
> On Wed, 2012-06-20 at 10:21 +0200, Stefan Priebe - Profihost AG wrote:
>> Am 20.06.2012 09:22, schrieb Eric Dumazet:
> Yes, you already told that in subject line.
>
> single tcp flow ?
I use iperf - i think it uses just a single tcp flow. But i'm not sure.

> You seem to have a switch or something that drops packets in this case.
> You could try to rate limit to 9Gb/s and see if it is better.
Sadly i can't rate limit to 9Gbit/s on the switch.

> Here, I roughly have same bandwidth with tcp_timestamps on or off, with
> ixgbe cards and net-next kernels.
Mhm strange. Do you have any vague idea what could cause this? Any wrong 
reordering of the packets without tcp_timestamps?

Stefan
