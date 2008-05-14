From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [RFC] [DCCP]: Deprecate SOCK_DCCP in favour of SOCK_DGRAM
Date: Wed, 14 May 2008 09:09:42 +0100
Message-ID: <20080514080942.GB4462@gerrit.erg.abdn.ac.uk>
References: <20080513093718.GA24185@gerrit.erg.abdn.ac.uk> <20080513162325.GF15306@ghostprotocols.net> <20080513170325.GB11499@gerrit.erg.abdn.ac.uk> <200805132037.39580.rdenis@simphalempin.com> <4829E87F.1070006@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: R?mi Denis-Courmont <rdenis@simphalempin.com>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	David Stevens <dlstevens@us.ibm.com>,
	David Miller <davem@davemloft.net>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
To: Ulrich Drepper <drepper@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:33231 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759846AbYENIYo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2008 04:24:44 -0400
Content-Disposition: inline
In-Reply-To: <4829E87F.1070006@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

|=20
| R=E9mi Denis-Courmont wrote:
| > In any case, getaddrinfo() should be patched to
| > [...]
|=20
| What should be the behavior is socktype and protocol are zero?  Shoul=
d
| these two types be returned by default?  What others?  So far we retu=
rn
| TCP, UDP, and raw socket information.  I'd rather keep the list short
| but since we already have raw sockets in there (because they are in
| POSIX) I won't reject anything that's more useful than raw sockets.
|=20
| - --
RFC 3493 says that 0 for socktype/protocol means that caller will accep=
t
any socket type / protocol, so presumably this does include DCCP and UD=
P-Lite.

It would be just _great_ if getaddrinfo() could support Remi's cases fo=
r DCCP
(RFC 4340) and UDP-Lite (RFC 3828). So far it is only possible to get a=
n
address by "cheating", i.e. pretending to getaddrinfo to be TCP or UDP.=
 This
does not really work well and still causes lots of problems/broken appl=
ications.

Gerrit
