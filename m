From: =?UTF-8?Q?R=C3=A9mi_Denis-Courmont?= <remi@remlab.net>
Subject: Re: [PATCH net-next-2.6] phonet: use =?UTF-8?Q?call=5Frcu=20for=20phonet?=
 =?UTF-8?Q?=20device=20free?=
Date: Mon, 07 Jun 2010 15:43:16 +0200
Message-ID: <474f08fed4a406e929af3d4142d3e185@chewa.net>
References: <20100607132738.GB2730@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:39122 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751994Ab0FGNnS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jun 2010 09:43:18 -0400
In-Reply-To: <20100607132738.GB2730@psychotron.lab.eng.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 7 Jun 2010 15:27:39 +0200, Jiri Pirko <jpirko@redhat.com> wrote=
:=0D
> Use call_rcu rather than synchronize_rcu.=0D
> =0D
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>=0D
=0D
This looks fine to me, but what is the goal here? The RCU documentation=
=0D
seems to imply that synchronize_rcu() is preferable over call_rcu() whe=
n at=0D
all possible.=0D
=0D
-- =0D
R=C3=A9mi Denis-Courmont=0D
http://www.remlab.net=0D
http://fi.linkedin.com/in/remidenis

