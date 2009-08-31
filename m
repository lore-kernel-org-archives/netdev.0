From: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Subject: Re: UDP is bypassing qdisc statistics ....
Date: Tue, 1 Sep 2009 06:28:40 +0930
Message-ID: <20090901062840.f1c25757.lk-netdev@lk-netdev.nosense.org>
References: <alpine.DEB.1.10.0908311632170.1507@V090114053VZO-1>
	<4A9C2A89.9060002@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christoph Lameter <cl@linux-foundation.org>,
	netdev@vger.kernel.org, davem@linux-foundation.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.adam.net.au ([202.136.110.247]:45039 "EHLO
	smtp4.adam.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751362AbZHaU6p convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 16:58:45 -0400
In-Reply-To: <4A9C2A89.9060002@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 31 Aug 2009 21:54:49 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Christoph Lameter a =E9crit :
> > This is with 2.6.31-rc7. If I send icmp then its correctly register=
ed as a
> > packet by the qdisc layer:
> >=20
<snip>
>=20
> loopback device do bypass qdisc layer for example...

On occassion, I'd have found it useful if it didn't. It'd be convenient
to test out your qdisc config, or test out applications performance
behaviour over a simulated WAN via netem, without having to a
network and two hosts, and all the related miscellaneous setup work.
