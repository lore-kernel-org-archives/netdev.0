From: Rick Jones <rick.jones2@hp.com>
Subject: Re: PROBLEM: Bnx2x Checksum/Length Error Over GRE Tunnel
Date: Tue, 03 Feb 2015 11:29:28 -0800
Message-ID: <54D12198.1000507@hp.com>
References: <54D0A345.2030108@skyatlas.com> <54D10DFE.1070604@skyatlas.com> <1422989196.907.34.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Network Development <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	=?UTF-8?B?RXJlbiBUw7xya2F5?= <erent@skyatlas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g9t1613g.houston.hp.com ([15.240.0.71]:60363 "EHLO
	g9t1613g.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966159AbbBCT3g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2015 14:29:36 -0500
In-Reply-To: <1422989196.907.34.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/03/2015 10:46 AM, Eric Dumazet wrote:
> On Tue, 2015-02-03 at 20:05 +0200, Eren T=C3=BCrkay wrote:
>> Hello,
>>
>> I am having incorrect checksum and length calculation error when usi=
ng
>> GRE tunnel and this leads to unstable/unreliable connections where e=
ven
>> simple nc connection cannot be made correctly due to a lot of TCP
>> retransmissions. The reported iperf output becomes 23Kbit/s.
>>
>> When I disable tx checksumming with "ethtool -K eth0 tx off", the
>> problem seems to be solved but then I lose tcp segmentation offloadi=
ng
>> support, without which adds an additional overhead on 10Gbit network
>> interface. With tx off, I get 4 to 7Gbit/s with parallel 40 connecti=
ons
>> using iperf.
>>
>> In tcpdump output (tcpdump -i em1 proto gre) when tx checksumming is
>> enabled, I see "checksum error" in every packet + "IP truncated-ip -
>> 63631 bytes missing!" messages, and a lot of TCP
>> retransmissions. When tx is off, checksums are correct but I get 4-7=
Gbit
>> output. With GSO generalization code in [0] it is reported that
>> 9.3Gbit/s is possible over GRE tunnel but I'm nowhere near these res=
ults.
>
> Strange, I am using bnx2x with no such problem.

A pedantic question, but do the driver and firmware versions match=20
between your setup and his?

rick
