From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Subject: Re: unstable 10GBE performance with recent kernels (> 3.0.X)
Date: Mon, 18 Jun 2012 16:17:15 +0200
Message-ID: <4FDF386B.1040300@profihost.ag>
References: <4FDEF34C.808@profihost.ag>  <1340012706.7491.770.camel@edumazet-glaptop>  <4FDEFD55.7010204@profihost.ag>  <1340015143.7491.855.camel@edumazet-glaptop>  <4FDF20B2.2010603@profihost.ag>  <1340023876.7491.1153.camel@edumazet-glaptop>  <4FDF2829.6050705@profihost.ag> <1340026144.7491.1231.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.profihost.ag ([85.158.179.208]:38298 "EHLO
	mail.profihost.ag" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751466Ab2FRORS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2012 10:17:18 -0400
In-Reply-To: <1340026144.7491.1231.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 18.06.2012 15:29, schrieb Eric Dumazet:
>> But with the latest long term stable vanilla kernel 3.0.34.
>>
>> # iperf -c HOST -t 60
>>
>> works fine but with -d for using both directions i see around 9.8Gbit/s
>> in one direction and only 300kb/s in the other direction.
>
> I would try using regular MTU.
For 3.5.0-rc2 this works fine but decreases the speed from 9,9Gbit/s to 
9,3Gbit/s. With mtu 9000 i get around 3-4Gbit/s (netstat -s attached below)

With 3.0.34 MTU 9000 works fine with constant 9,9Gbit/s in both directions.

> And post "netstat -s" results before/after your iperf.

Tests with mtu 9000 and 3.5rc2:
Pre: http://pastebin.com/raw.php?i=uBjsFKjs
Post: http://pastebin.com/raw.php?i=TAK8JS6j

Thanks again!

Stefan
