From: =?UTF-8?B?UGF3ZcWCIFN0YXN6ZXdza2k=?= <pstaszewski@itcare.pl>
Subject: Re: [ SPAM ] Re: Is this normal?
Date: Tue, 27 Jan 2009 15:26:08 +0100
Message-ID: <497F1980.1070008@itcare.pl>
References: <497F14B1.7070306@itcare.pl> <497F16F7.6020504@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Network Development list <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.iq.pl ([86.111.241.19]:57914 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753291AbZA0O0L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jan 2009 09:26:11 -0500
In-Reply-To: <497F16F7.6020504@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy pisze:
> Pawe=C5=82 Staszewski wrote:
>> I have Linux that works as Router + traffic management with=20
>> connection tracking enabled but without making NAT
>>
>> About 600Mbit/s TX and 600Mbit/s RX forwarded traffic
>>
>> iptables -L -n -v -t raw
>> Chain PREROUTING (policy ACCEPT 3340M packets, 2623G bytes)
>> pkts bytes target     prot opt in     out     source              =20
>> destination
>> 3339M 2621G NOTRACK    all  --  *      *       0.0.0.0/0           =20
>> 0.0.0.0/0
>>
>>
>> kernel 2.6.28.2
>> CPU: Core 2, speed 2999.98 MHz (estimated)
>> Counted CPU_CLK_UNHALTED events (Clock cycles when not halted) with =
a=20
>> unit mask of 0x00 (Unhalted core cycles) count 100000
>> samples  %        image name               app name                =20
>> symbol name
>> 14544205 15.8604  vmlinux                  vmlinux                 =20
>> ctnetlink_del_expect
>
> This doesn't seem to be accurate, I'm guessing its really
> ctnetlink_conntrack_event().
>
> Does this patch make any difference?

I will check this patch today at night.

