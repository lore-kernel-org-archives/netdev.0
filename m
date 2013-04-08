From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: v3.8.5: "TCP: snd_cwnd is nul, please report this bug."
Date: Mon, 08 Apr 2013 17:42:29 +0200
Message-ID: <87wqsdghay.fsf@nemi.mork.no>
References: <87zjx9pf13.fsf@nemi.mork.no>
	<1365431422.3887.10.camel@edumazet-glaptop>
	<87li8tyrzs.fsf@nemi.mork.no>
	<1365434301.3887.14.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:48711 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936454Ab3DHPpN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 11:45:13 -0400
In-Reply-To: <1365434301.3887.14.camel@edumazet-glaptop> (Eric Dumazet's
	message of "Mon, 08 Apr 2013 08:18:21 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:

> I believe patch applies (with some fuzz) on Linus tree, and maybe on =
3.8
> too.

Probably just a minor context issue, but it failed like this on v3.9-rc=
6
(as well as 'net' and v3.8.6):

     Applying: v3.8.5: "TCP: snd_cwnd is nul, please report this bug."
     error: patch failed: net/ipv4/tcp_westwood.c:233
     error: net/ipv4/tcp_westwood.c: patch does not apply


I'll just run todays net-next with this on top.  No problem.



Bj=C3=B8rn
