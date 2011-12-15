From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: twice past the taps, thence out to net?
Date: Wed, 14 Dec 2011 18:12:53 -0800
Message-ID: <CAGK4HS-+jj9cvvirDm96oRvRJdwC+2kjE_LnSOXBuQy0pfnQjg@mail.gmail.com>
References: <4EE8F884.1010304@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: tcpdump-workers@lists.tcpdump.org, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:49446 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755804Ab1LOCMy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2011 21:12:54 -0500
Received: by vcbfk14 with SMTP id fk14so1156423vcb.19
        for <netdev@vger.kernel.org>; Wed, 14 Dec 2011 18:12:53 -0800 (PST)
In-Reply-To: <4EE8F884.1010304@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14 December 2011 11:27, Rick Jones <rick.jones2@hp.com> wrote:
> While looking at "something else" with tcpdump/tcptrace, tcptrace emi=
tted
> lots of notices about hardware duplicated packets being detected (sam=
e TCP
> sequence number and IP datagram ID). =A0Sure enough, if I go into the=
 tcpdump
> trace (taken on the sender) I can find instances of what it was talki=
ng
> about, separated in time by rather less than I would expect to be the=
 RTO,
> and often as not with few if any intervening arriving ACKs to trigger
> anything like fast retransmit. =A0And besides, those would have a dif=
ferent IP
> datagram ID no?
>
> I did manage to reproduce the issue with plain netperf tcp_stream tes=
ts. I
> had one sending system with 30 concurrent netperf tcp_stream tests to=
 30
> other receiving systems. =A0There are "hardware duplicates" in the se=
nding
> trace, but no duplicate segments (that I can find thus far) in the tw=
o
> receiver side traces I took. =A0Of course that doesn't mean "conclusi=
vely"
> there were two actual sends but it suggests there werent.
>
> While I work through the "obtain permission" path to post the packet =
traces
> (don't ask...) I thought I would ask if anyone else has seen somethin=
g
> similar.
>
> In this case, all the systems are running a 2.6.38-8 Ubuntu kernel (t=
he same
> sorts of issues which delay my just putting the traces up on netperf.=
org
> preclude a later kernel, and I've no other test systems :( ), with In=
tel
> 82576 interfaces being driven by:
>
> $ sudo ethtool -i eth0
> driver: igb
> version: 2.1.0-k2
> firmware-version: 1.8-2
> bus-info: 0000:05:00.0
>
> All the systems were connected to the same switch.
>

Rick,
This may be of help.
http://www.tcptrace.org/faq_ans.html#FAQ%2021

Regards,
Vijay Subramanian
