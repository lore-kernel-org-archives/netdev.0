From: =?utf-8?q?R=C3=A9mi_Denis-Courmont?= <rdenis@simphalempin.com>
Subject: Re: [PATCH 1/5] Phonet: allocate a non-Ethernet ARP type
Date: Thu, 18 Dec 2008 00:18:43 +0200
Message-ID: <200812180018.44988@auguste.remlab.net>
References: <200812171607.14184.remi.denis-courmont@nokia.com> <1229522874-20636-1-git-send-email-remi.denis-courmont@nokia.com> <1229544449.10889.19.camel@violet>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?q?R=C3=A9mi_Denis-Courmont?=
	<remi.denis-courmont@nokia.com>, netdev@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:58664 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751607AbYLQWSu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 17:18:50 -0500
In-Reply-To: <1229544449.10889.19.camel@violet>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 17 d=C3=A9cembre 2008, Marcel Holtmann a =C3=A9crit :
> what kind of communication are you doing over that device.

Phonet packets on the wire. That is to say, Phonet packets including th=
e=20
leading media type byte, which the Linux Phonet implementation consider=
=20
to be the Phonet "link-layer", and is not visible to the Phonet sockets=
=20
stack.

No IP here.

--=20
R=C3=A9mi Denis-Courmont
http://www.remlab.net/
