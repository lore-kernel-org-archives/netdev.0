From: alekcejk@googlemail.com
Subject: Re: Re: limited network bandwidth with 3.2.x kernels
Date: Thu, 16 Feb 2012 19:54:54 +0200
Message-ID: <1461927.R8CTCUdqT9@localhost.localdomain>
References: <1329399616.9395.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <20120216.120149.437368615973561397.davem@davemloft.net> <CADVnQykm==YJZbdCbLxgJ236jD2yN0xT99gmeYX-FGnyBvfEGA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Neal Cardwell <ncardwell@google.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:49914 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753944Ab2BPSDb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2012 13:03:31 -0500
Received: by bkcjm19 with SMTP id jm19so2231195bkc.19
        for <netdev@vger.kernel.org>; Thu, 16 Feb 2012 10:03:30 -0800 (PST)
In-Reply-To: <CADVnQykm==YJZbdCbLxgJ236jD2yN0xT99gmeYX-FGnyBvfEGA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=F7 =D3=CF=CF=C2=DD=C5=CE=C9=C9 =CF=D4 =FE=C5=D4=D7=C5=D2=C7 16 =C6=C5=D7=
=D2=C1=CC=D1 2012 12:22:29 =D7=D9 =CE=C1=D0=C9=D3=C1=CC=C9:
> Our team has also run into issues with GRO/LRO "stretch ACKs", and
> their negative impact on TCP performance. We have a patch that we've
> been working with that deals with the sender-side issues. It turns ou=
t
> that neither the ABC nor non-ABC byte counting quite fixes the stretc=
h
> ACKs issues.
>=20
> On the receiver side, the approach of changing tcp_grow_window() and
> __tcp_grow_window() to adjust things in terms of actual packet size
> rather than a fixed 2*MSS sounds great to me as well.
>=20
> In terms of the original 3.1 vs 3.2 issue report that started this
> thread, I didn't see any evidence of LRO or GRO causing stretch ACKs.
> (Alexey, would you be able to confim by running "ethtool -k eth0" on
> both kernels?) So it seems that probably the original issue is
> unrelated to stretch ACKs?
>=20
> neal

Looks like  "ethtool -k eth0" shows the same with both kernels:

Offload parameters for eth0:
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp-segmentation-offload: off
udp-fragmentation-offload: off
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off
rx-vlan-offload: off
tx-vlan-offload: off
ntuple-filters: off
receive-hashing: off
