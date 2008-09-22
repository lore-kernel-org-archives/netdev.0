From: "=?ISO-8859-1?Q?Ra=FAl_Hern=E1ndez?=" <rauhersu@gmail.com>
Subject: Re: routing PF_PACKET sockets
Date: Mon, 22 Sep 2008 15:39:59 +0200
Message-ID: <3f847c820809220639y609470b6x9b2602cba24a0589@mail.gmail.com>
References: <3f847c820809211610n731b0090wb6a9f94a3514f455@mail.gmail.com>
	 <5c4c427193d751928b131d43ab66879f@chewa.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "=?ISO-8859-1?Q?R=E9mi_Denis-Courmont?=" <rdenis@simphalempin.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.180]:38830 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752105AbYIVNj7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 09:39:59 -0400
Received: by wa-out-1112.google.com with SMTP id j37so1247123waf.23
        for <netdev@vger.kernel.org>; Mon, 22 Sep 2008 06:39:59 -0700 (PDT)
In-Reply-To: <5c4c427193d751928b131d43ab66879f@chewa.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Remi,

Just to clarify it a bit more; Suppose that a user app has two
PF_PACKET sockets (SOCK_RAW) over eth0 and eth1 (to ensure redundancy)
to send data to the network. In case eth0 is down, it would be
useless, for example, move the routing table entries which reference
eth0 to eth1 as the app which sends data to the network bypasses any
routing policy (I think this would do if my app used standard tcp
sockets).

Right ?

Best regards,
Ra=FAl




On Mon, Sep 22, 2008 at 12:54 PM, R=E9mi Denis-Courmont
<rdenis@simphalempin.com> wrote:
>
> On Mon, 22 Sep 2008 01:10:54 +0200, "Ra=FAl Hern=E1ndez" <rauhersu@gm=
ail.com>
> wrote:
>> I am trying to understand the possible options on dealing with
>> PF_PACKET and routing schemas: does the packet bypass the linux
>> routing table (as it is opened directly over a 'dev').
>
> Yes, by design.
>
>> Might this behaviour be configurable ?
>
> No. Use raw sockets from the adequate protocol family, if you want to
> inject packets into the network layer.
>
> --
> R=E9mi Denis-Courmont
>
>



--=20
Security is mostly a superstition. It does not exist in nature nor do
the children of man as a whole experience it. Avoiding danger is no
safer in the long run than outright exposure. Life is either a daring
adventure, or nothing - Helen Keller
