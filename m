From: Yuehai Xu <yuehaixu@gmail.com>
Subject: Re: How do I know my driver support RSS?
Date: Sat, 3 Mar 2012 23:30:36 -0500
Message-ID: <CAEc1PS0OhdbVD_tUurNO2rk_w_VSewSNWirq2w6LwZCsZoBisQ@mail.gmail.com>
References: <CAEc1PS1j2DL4m7B1Rp9nseqLWsxaXXY+ZJDHra+99c5-WPgYcQ@mail.gmail.com>
	<1330819855.8460.291.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>, yhxu@wayne.edu,
	sbw@mit.edu
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1330819855.8460.291.camel@deadeye>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Mar 3, 2012 at 7:10 PM, Ben Hutchings <bhutchings@solarflare.co=
m> wrote:
> On Sat, 2012-03-03 at 16:25 -0500, Yuehai Xu wrote:
> [...]
>> Since I read the following statements from a paper, "we use a separa=
te
>> hardware receive and transmit queue for each core and configure the
>> IXGBE to inspect the port number in each incoming packet header, pla=
ce
>> the packet on the queue dedicated to the associated memcached's core=
,
>> and deliver the receive interrupt to that core." and the background =
of
>> this configuration is that each memcached is pinned to a separate co=
re
>> and has its own UDP port. It seems that IXGBE's driver can detect UD=
P
>> packets according to their port numbers and put these packets into
>> corresponding receive queues in the hardware, is this achieved by
>> configuring RSS in IXGBE? If it is, I am wondering whether bnx2
>> supports RSS and whether it can configure in the same way.
>>
>> I appreciate any help for this.
>
> You're confusing RSS (flow hashing) with flow steering. =A0These are =
both
> explained in Documentation/network/scaling.txt.
>
> Ben.
>
I appreciate your replying!! What confuses me is that for each UDP
socket with exclusive port number, it has RX queue in transport layer,
and network card might also have multiple RX queues. These two queues
are definitely different. So, is it possible to configure network card
to put packets to queues(RX queues in network card) according to hash?
I read the codes of RPS/RFS, it seems that packets are put into queues
in transport layer of sockets instead of queues in network card. Am I
correct?

I appreciate any replies.

Yuehai
