From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: Re: GRO aggregation
Date: Tue, 11 Sep 2012 15:20:12 -0300
Message-ID: <504F80DC.7010707@redhat.com>
References: <504F4063.9030706@mellanox.com>
Reply-To: mleitner@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Shlomo Pongartz <shlomop@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23747 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756996Ab2IKSUa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Sep 2012 14:20:30 -0400
In-Reply-To: <504F4063.9030706@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/11/2012 10:45 AM, Shlomo Pongartz wrote:
> Hi,
>
> I=92m checking GRO aggregation with kernel 3.6.0-rc1+ using Intel ixg=
be
> driver.
> The mtu is 1500 and GRO is on and so are SG and RX checksum.
> I ran iperf with default setting and monitor the receiver with tcpdum=
p.
> The tcpdump shows that the maximal aggregation is 32120 which is 21 *=
 1500.
> In the transmitter side tcpdump shows that TSO works better (~64K).
> I did a capture without GRO enabled to see if there was a difference
> between any flag
> of any two consecutive packets that forced flushing but didn't find
> anything.
> Is the GRO aggregation can be tuned.

Hi Shlomo,

Have you tried tuning coalescing parameters?

Marcelo
