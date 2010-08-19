From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: Re: [PATCH v2] netfilter: save the hash of the tuple in the
	original direction for latter use
Date: Thu, 19 Aug 2010 12:11:12 -0400
Message-ID: <20100819161112.GA24357@Krystal>
References: <1282228389-3029-1-git-send-email-xiaosuo@gmail.com> <20100819152149.GA19744@Krystal> <AANLkTim5wn0Y-+081gvm7FkWx3NioRvtRMWy2uF4nji2@mail.gmail.com> <1282232786.2549.60.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>, Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tomts13.bellnexxia.net ([209.226.175.34]:46167 "EHLO
	tomts13-srv.bellnexxia.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752953Ab0HSQLZ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Aug 2010 12:11:25 -0400
Content-Disposition: inline
In-Reply-To: <1282232786.2549.60.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Eric Dumazet (eric.dumazet@gmail.com) wrote:
> Le jeudi 19 ao=FBt 2010 =E0 23:35 +0800, Changli Gao a =E9crit :
>=20
> >=20
> > In fact, I don't know the reason clearly. This code is derived from
> > the older one. Maybe there isn't enough entropy when initializing.
> >=20
>=20
> Yes, we wanted to initialize these random data as late as possible, t=
hat
> is when the first entry is added in conntrack hash.

Ah, I see. But I think the static variable should stay declared outside
of the function scope, with a nice comment explaining why it's not
initialized at init-time.

Hiding global state in function code is usually frowned upon.

Thanks,

Mathieu


--=20
Mathieu Desnoyers
Operating System Efficiency R&D Consultant
EfficiOS Inc.
http://www.efficios.com
