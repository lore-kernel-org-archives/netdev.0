From: Emanuil Hristov <int986@gmail.com>
Subject: Re: Ethernet-over-UDP virtual network interface
Date: Sun, 4 Mar 2012 18:24:19 +0200
Message-ID: <CAFnNQmyhadb-m9hZD+GBhoF0CRKYL5q=fA7EOzHtf8Ds4_187g@mail.gmail.com>
References: <CAKLmikOBPB7rTZu2EfK26=3AhOQUR8xg8n4ySUKRMFmBkC1J3g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Nejc Skoberne <nejc@skoberne.net>,
	Jernej Kos <kostko@unimatrix-one.org>, gw.2012@tnode.com,
	int986@gmail.com
To: Mitar <mmitar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:49711 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751002Ab2CDQYU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2012 11:24:20 -0500
Received: by gghe5 with SMTP id e5so610188ggh.19
        for <netdev@vger.kernel.org>; Sun, 04 Mar 2012 08:24:19 -0800 (PST)
In-Reply-To: <CAKLmikOBPB7rTZu2EfK26=3AhOQUR8xg8n4ySUKRMFmBkC1J3g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi
you can try l2tp(v3) :) i think it fit best for your needs

Best regards

On Sun, Mar 4, 2012 at 1:30 PM, Mitar <mmitar@gmail.com> wrote:
> Hi!
>
> At community wireless network wlan slovenija (http://dev.wlan-si.net/=
)
> we have been using OpenVPN tunnels to connect our WiFi nodes together
> over existing Internet infrastructure. After some time of using it we
> have discovered throughput problems using a user-land tunneling
> solution on those small/consumer Wifi router hardware. Because of the
> context switches we cannot get more than 5 Mbit/s even with disabled
> encryption. (And as we have a lot of fiber here, it really makes
> uplinks unused a lot.)
>
> We found out that we need a really light-weight tunneling solution,
> but on a L2 level. The idea is to have a simple encryption-less,
> state-less, and session-less L2 tunneling. Some kind of
> Ethernet-over-UDP type of virtual interface where we could configure
> multiple peer IP address and virtual interface would work as a simple
> switch, only instead of cables, it would send packets encapsulated in
> UDP (EoIP is not good because many consumer routers do not allow
> non-TCP/UDP packets to get through). No session handling, nothing.
> Simply, any packets it gets in it is send (based on auto-learned MAC
> addresses) to the destination IP address in the UDP packet. On the
> other side decapsulated packet is simply output of the virtual
> interface there.
>
> I have searched around and have not found anything which would work
> like this. Have I missed something? If not, I have decided to write
> our own kernel module for this, but first I would like to hear some
> feedback from others. Would anybody be interested in developing it
> with me or at mentoring me (it would be my first kernel module)?
>
> I have found this code:
>
> https://lwn.net/Articles/199120/
>
> and was planning to use it as a basis, but use UDP for communication.
> What is a proper way to do UDP communication from a kernel module?
>
> Best regards and thank you all for the great work you are doing on Li=
nux
>
>
> Mitar
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
