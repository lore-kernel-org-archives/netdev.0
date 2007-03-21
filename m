From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: many sockets, slow sendto
Date: Wed, 21 Mar 2007 23:24:16 +0100
Message-ID: <4601B090.9060704@cosmosbay.com>
References: <E1HObHK-0000WB-00@osiris.swi.hu>	<20070306182039.GJ25760@galon.ev-en.org>	<45FF185B.4070007@fw.hu> <20070319.161611.70218081.davem@davemloft.net> <4600592E.80605@fw.hu> <460064C6.5030302@cosmosbay.com> <4601A949.2000005@fw.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, baruch@ev-en.org,
	netdev@vger.kernel.org
To: Zacco <zacco@fw.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.cosmosbay.com ([86.65.150.131]:44822 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S965381AbXCUWYp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2007 18:24:45 -0400
In-Reply-To: <4601A949.2000005@fw.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Zacco a =E9crit :
> Actually, the source address would be more important in my case, as m=
y=20
> clients (each with different IP address) wants to connect to the same=
=20
> server, i.e. to the same address and port.

I dont understand why you need many sockets then.

A single socket should be enough.

> I think, the current design is fair enough for server implementations=
=20
> and for regular clients. But even though my application is not tipica=
l,=20
> as far as I know (but it can be important with the fast performance=20
> growth of regular PCs), the make-up should be general enough to cope=20
> with special circumstances, like mine. My initial idea was to somehow=
=20
> include the complete socket pair, i.e. source address:port and=20
> destination address:port, keeping in mind that it should work for bot=
h=20
> IPv4 and IPv6. Maybe it's an overkill, I don't know.

Could you send me a copy of your application source, or detailed specs,=
=20
because I am confused right now...


