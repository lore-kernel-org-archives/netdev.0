From: =?ISO-8859-1?Q?Mart=EDn_Ferrari?= <martin.ferrari@gmail.com>
Subject: Announcing the netns library
Date: Thu, 16 Sep 2010 15:31:03 +0200
Message-ID: <AANLkTikw8qb7Gv11VpWFgeafp3qs=5cVHRihRXh5_dA2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mathieu Lacage <mathieu.lacage@sophia.inria.fr>,
	Alina Quereilhac <Alina.Quereilhac@sophia.inria.fr>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:53031 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751456Ab0IPNbE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Sep 2010 09:31:04 -0400
Received: by iwn5 with SMTP id 5so1084078iwn.19
        for <netdev@vger.kernel.org>; Thu, 16 Sep 2010 06:31:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

After a few months pestering this list with my bugs, I would like to
bive something back by showing what I have been working on, in case it
is useful for somebody.

The netns library is a Python library that tries to make it easy to
create a virtual network with realistic characteristics. It uses
namespaces for the virtual nodes, veth links and bridges to connect
them, and netem+tbf to emulate real world conditions. It is mainly
aimed at network research, and it is part of a bigger project called
NEPI, but I think netns is useful on its own, even when you just need
something to handle all the painful configuration to set up
namespaces.

Of course, at this stage the API is not stable, and there are bugs,
but the basic functionality is there.

You can see more information about it here:
http://yans.pl.sophia.inria.fr/trac/nepi/wiki/netns
The mercurial repository is here:
http://yans.pl.sophia.inria.fr/trac/nepi/wiki/netns

A sample script to show the basic usage:
http://yans.pl.sophia.inria.fr/code/hgwebdir.cgi/netns/file/tip/sample.=
py

Don't hesitate to contact me if you are interested or have doubts.

Mart=EDn.

--=20
Mart=EDn Ferrari
