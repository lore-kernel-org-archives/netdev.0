From: Florian Weimer <fweimer@bfk.de>
Subject: Re: Beyond 64K TCP connections limit per IP-address
Date: Wed, 04 Jul 2007 10:19:50 +0200
Message-ID: <82sl84pom1.fsf@mid.bfk.de>
References: <7e63f56c0707040050k7d1a9daeq276d7d924ef802e8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: NetDev <netdev@vger.kernel.org>
To: "Robert Iakobashvili" <coroberti@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx01.bfk.de ([193.227.124.2]:56076 "EHLO mx01.bfk.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756127AbXGDIhc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jul 2007 04:37:32 -0400
In-Reply-To: <7e63f56c0707040050k7d1a9daeq276d7d924ef802e8@mail.gmail.com> (Robert Iakobashvili's message of "Wed, 4 Jul 2007 09:50:31 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Robert Iakobashvili:

> If I am correct, a TCP server can make up to
> 64K accepts for a port at a single IP-address.

I don't think such a limit exists.  In typical configurations, a
single client IP address can only establish a few tens of thousands of
TCP connections to one server port.  But as soon as multiple clients
are involved, there is virtually no protocol-imposed limit.

--=20
=46lorian Weimer                <fweimer@bfk.de>
BFK edv-consulting GmbH       http://www.bfk.de/
Kriegsstra=DFe 100              tel: +49-721-96201-1
D-76133 Karlsruhe             fax: +49-721-96201-99
