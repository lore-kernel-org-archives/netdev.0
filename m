From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: Re: GRO aggregation
Date: Tue, 11 Sep 2012 15:48:13 -0300
Message-ID: <504F876D.9020102@redhat.com>
References: <504F4063.9030706@mellanox.com>,<504F80DC.7010707@redhat.com> <36F7E4A28C18BE4DB7C86058E7B607241E622015@MTRDAG01.mtl.com>
Reply-To: mleitner@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Shlomo Pongratz <shlomop@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54323 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751895Ab2IKSsT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Sep 2012 14:48:19 -0400
In-Reply-To: <36F7E4A28C18BE4DB7C86058E7B607241E622015@MTRDAG01.mtl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/11/2012 03:41 PM, Shlomo Pongratz wrote:
> From: Marcelo Ricardo Leitner [mleitner@redhat.com]
> Sent: Tuesday, September 11, 2012 9:20 PM
> To: Shlomo Pongratz
> Cc: netdev@vger.kernel.org
> Subject: Re: GRO aggregation
>
> On 09/11/2012 10:45 AM, Shlomo Pongartz wrote:
>> Hi,
>>
>> I=92m checking GRO aggregation with kernel 3.6.0-rc1+ using Intel ix=
gbe
>> driver.
>> The mtu is 1500 and GRO is on and so are SG and RX checksum.
>> I ran iperf with default setting and monitor the receiver with tcpdu=
mp.
>> The tcpdump shows that the maximal aggregation is 32120 which is 21 =
* 1500.
>> In the transmitter side tcpdump shows that TSO works better (~64K).
>> I did a capture without GRO enabled to see if there was a difference
>> between any flag
>> of any two consecutive packets that forced flushing but didn't find
>> anything.
>> Is the GRO aggregation can be tuned.
>
> Hi Shlomo,
>
> Have you tried tuning coalescing parameters?
>
> Marcelo
>
>
> Hi Marcelo
>
> I didn't play with interrupts coalescing.
> Do you suggest to increase the value?

Actually it was an idea from top of my mind, I don't know how it applie=
s=20
to ixgbe, sorry. But making the NIC hold the packets a bit more should=20
make it send larger ones to kernel. Trade-off between latency/throughpu=
t.

I was thinking about ethtool -c options, like rx-usecs*

Marcelo
