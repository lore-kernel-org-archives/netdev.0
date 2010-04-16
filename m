From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v5] rfs: Receive Flow Steering
Date: Fri, 16 Apr 2010 23:12:38 +0200
Message-ID: <1271452358.16881.4486.camel@edumazet-laptop>
References: <alpine.DEB.1.00.1004152243470.15102@pokey.mtv.corp.google.com>
	 <20100415.233334.242114544.davem@davemloft.net>
	 <1271401007.16881.3762.camel@edumazet-laptop>
	 <l2m65634d661004161135h1c1466afi54787022bfc2ce12@mail.gmail.com>
	 <1271443994.16881.4249.camel@edumazet-laptop>
	 <u2t65634d661004161342zeadb5602w73c369ec717dc6e1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:57644 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757887Ab0DPVMm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Apr 2010 17:12:42 -0400
Received: by bwz25 with SMTP id 25so3639754bwz.28
        for <netdev@vger.kernel.org>; Fri, 16 Apr 2010 14:12:41 -0700 (PDT)
In-Reply-To: <u2t65634d661004161342zeadb5602w73c369ec717dc6e1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 16 avril 2010 =C3=A0 13:42 -0700, Tom Herbert a =C3=A9crit =
:
> On Fri, Apr 16, 2010 at 11:53 AM, Eric Dumazet <eric.dumazet@gmail.co=
m> wrote:
> > Le vendredi 16 avril 2010 =C3=A0 11:35 -0700, Tom Herbert a =C3=A9c=
rit :
> >> Results with "tbench 16" on an 8 core Intel machine.
> >>
> >> No RPS/RFS:  2155 MB/sec
> >> RPS (0ff mask): 1700 MB/sec
> >> RFS: 1097
> >>
>=20
> Blah, I mistakingly reported that... should have been:
>=20
> No RPS/RFS:  2155 MB/sec
> RPS (0ff mask): 1097 MB/sec
> RFS: 1700 MB/sec
>=20
> Sorry about that!

> This was my expectation too, and what my "corrected" numbers show :-)
> But, I take it this is different in your results?


My results are on a "tbench 16" on an dual X5570  @ 2.93GHz.
(16 logical cpus)

No RPS , no RFS : 4448.14 MB/sec=20
RPS : 2298.00 MB/sec (but lot of variation)
RFS : 2600 MB/sec

Maybe my RFS setup is bad ?
(8192 flows)


