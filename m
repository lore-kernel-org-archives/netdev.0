From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Subject: Re: 10GBE performance drop with net.ipv4.tcp_timestamps=0
Date: Wed, 20 Jun 2012 09:00:50 +0200
Message-ID: <4FE17522.5050005@profihost.ag>
References: <4FE0EA33.1000309@profihost.ag> <1340141493.4604.773.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.profihost.ag ([85.158.179.208]:56018 "EHLO
	mail.profihost.ag" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751209Ab2FTHA4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2012 03:00:56 -0400
In-Reply-To: <1340141493.4604.773.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 19.06.2012 23:31, schrieb Eric Dumazet:
> On Tue, 2012-06-19 at 23:08 +0200, Stefan Priebe wrote:
>> i'm testing 10GBE speed with tweo servers. One with 3.5-rc3 nd thoe
>> other one whith RHEL 6 (2.6.32 kernel).
>>
>> I noticed that setting
>> net.ipv4.tcp_timestamps=0
>>
>> descreased the performance from 9,7 Full Duplex to 3-4Gb/s.
>>
>> Is this bahviour fine? What should / could i tet?
>>
>
> Really, you should provide more input than that, if you really want us
> to help.

*arg* forgot to add the pastebin links. Sorry. Speed degraded in this 
case from 9,88Gbit/s to 2,45Gbit/s. When i turn on timestamps it's 
perfect again. Server A has 3.5.0-rc3 and server B has an RHEL6 2.6.32 
kernel.

Before:
http://pastebin.com/raw.php?i=1gVraWVc

After:
http://pastebin.com/raw.php?i=NSh8Y29s

Thanks,
Stefan
