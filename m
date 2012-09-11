From: Shlomo Pongratz <shlomop@mellanox.com>
Subject: RE: GRO aggregation
Date: Tue, 11 Sep 2012 18:51:13 +0000
Message-ID: <36F7E4A28C18BE4DB7C86058E7B607241E62204C@MTRDAG01.mtl.com>
References: <504F4063.9030706@mellanox.com>,<504F80DC.7010707@redhat.com>
 <36F7E4A28C18BE4DB7C86058E7B607241E622015@MTRDAG01.mtl.com>,<504F876D.9020102@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=Windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "mleitner@redhat.com" <mleitner@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog104.obsmtp.com ([207.126.144.117]:39043 "HELO
	eu1sys200aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755879Ab2IKSvS convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Sep 2012 14:51:18 -0400
In-Reply-To: <504F876D.9020102@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Marcelo Ricardo Leitner [mleitner@redhat.com]
Sent: Tuesday, September 11, 2012 9:48 PM
To: Shlomo Pongratz
Cc: netdev@vger.kernel.org
Subject: Re: GRO aggregation

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
s
to ixgbe, sorry. But making the NIC hold the packets a bit more should
make it send larger ones to kernel. Trade-off between latency/throughpu=
t.

I was thinking about ethtool -c options, like rx-usecs*

Marcelo

I'll try to play with it a little.
Thanks.

Shlomo
