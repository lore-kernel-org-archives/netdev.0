From: Changli Gao <xiaosuo@gmail.com>
Subject: RFC: netfilter: synproxy iptables target
Date: Thu, 20 May 2010 17:46:06 +0800
Message-ID: <AANLkTimp6S7MpwDAT8l-M0ZWjs2HIcUEfL5f8j9-QDZh@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I have implemented a simple SYNPROXY iptables target. It is much like
the SYNPROXY implementation in pf of OpenBSD, but won't have state
until the first connection is established with the help of syncookies.
The code is hosted at github:

http://github.com/xiaosuo/xiaosuo/tree/master/synproxy/

Currently, it can work with firewall and local socket.

It is in the very early stage, and ugly. And I will add --timeout
parameter to this target as TCP_DFER_ACCEPT, so I can do NAT basing on
the request data.

i.e.

iptables -t nat -A OUTPUT -p tcp -m synproxy --http-url "*.jpg" -j
DNAT --to-destination $image_http_server:80

And is there any chance to merge it into mainline?

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
