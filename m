From: wanq <picktracy@gmail.com>
Subject: Re: Fwd: PROBLEM: IPv6 Duplicate Address Detection with non
 RFC-conform ICMPv6 packets
Date: Tue, 10 May 2011 19:14:05 +0800
Message-ID: <BANLkTinaXTa22Z_gMrqd+oD8cuTpnLN0cw@mail.gmail.com>
References: <4DC54157.9010306@computer.org>
	<1304773802.2821.1214.camel@edumazet-laptop>
	<dc9a790de083b31ff85c0b9578c980e7@mail.insa-lyon.fr>
	<1304774758.2821.1237.camel@edumazet-laptop>
	<842648e0f4a8c6f7cd8a47cd6916a939@mail.insa-lyon.fr>
	<1304777182.2821.1262.camel@edumazet-laptop>
	<6fc82268416d8f6cfd40ea8b1bc4ebdf@mail.insa-lyon.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jan Ceuleers <jan.ceuleers@computer.org>,
	netdev@vger.kernel.org
To: Gervais Arthur <arthur.gervais@insa-lyon.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:37066 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753185Ab1EJLOG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 07:14:06 -0400
Received: by yxs7 with SMTP id 7so2091295yxs.19
        for <netdev@vger.kernel.org>; Tue, 10 May 2011 04:14:05 -0700 (PDT)
In-Reply-To: <6fc82268416d8f6cfd40ea8b1bc4ebdf@mail.insa-lyon.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In fact, I think the implementation of Linux fully meet the RFC specifi=
cations.

Think about this, two nodes have the same MAC, the DAD of the
self-generated link-local address on the new one MUST NOT pass. And
the IPv6 traffic of the interface SHOULD be disabled, because there's
no better way to recover from MAC conflicts automatically.

2011/5/7 Gervais Arthur <arthur.gervais@insa-lyon.fr>:
> On 05/07/2011 04:06 PM, Eric Dumazet wrote:
> =A0> Le samedi 07 mai 2011 =E0 15:54 +0200, Gervais Arthur a =E9crit =
:
> =A0>
> =A0>> Why would the victim itself claim already having the IPv6 addre=
ss?
> =A0>>
> =A0>
> =A0> Why should it care ? Please point me the RFC saying its illegal =
to send
> =A0> or receive a frame with SRC_MAC =3D=3D DST_MAC
> =A0>
>
> There is no RFC statement saying that this is illegal. But we are not
> only talking about the Ethernet layer. There is also the ICMPv6 Layer=
=2E
>
> But neither in the IPv6 RFC's I can find something about this.
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>



--=20
wanq
