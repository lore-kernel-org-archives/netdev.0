From: Florian Weimer <fweimer@bfk.de>
Subject: Re: ntohs() and htons() usgae in the network stack
Date: Wed, 10 Jun 2009 16:10:16 +0200
Message-ID: <823aa8ch87.fsf@mid.bfk.de>
References: <55c333c0906100708q1b0be2ffkc80c2f3258f0e681@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Kevin Wilson <wkevils@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx01.bfk.de ([193.227.124.2]:48813 "EHLO mx01.bfk.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756302AbZFJOYc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 10:24:32 -0400
In-Reply-To: <55c333c0906100708q1b0be2ffkc80c2f3258f0e681@mail.gmail.com> (Kevin Wilson's message of "Wed\, 10 Jun 2009 17\:08\:12 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Kevin Wilson:

> So I wondered : when is ntohs(i) !=3D htons(i) ?

Never, for ordinary endieanness.  The operation is an involution, that
is, its own inverse (like mirroring).

--=20
=46lorian Weimer                <fweimer@bfk.de>
BFK edv-consulting GmbH       http://www.bfk.de/
Kriegsstra=DFe 100              tel: +49-721-96201-1
D-76133 Karlsruhe             fax: +49-721-96201-99
