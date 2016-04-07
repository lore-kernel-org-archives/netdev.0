From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 2/9] rxrpc: Disable a debugging statement that has been left enabled.
Date: Thu, 07 Apr 2016 21:42:34 +0100
Message-ID: <5417.1460061754@warthog.procyon.org.uk>
References: <1460060518.1800.8.camel@perches.com> <1460049545.6715.98.camel@perches.com> <1460046677.6715.95.camel@perches.com> <20160407162256.21283.47849.stgit@warthog.procyon.org.uk> <20160407162309.21283.11482.stgit@warthog.procyon.org.uk> <24286.1460048722@warthog.procyon.org.uk> <981.1460058224@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37798 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756795AbcDGUmh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 16:42:37 -0400
In-Reply-To: <1460060518.1800.8.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Perches <joe@perches.com> wrote:

> > Let's see...=C2=A0=C2=A0If the machine panics whilst I'm developing=
 stuff (quite
> > likely if something goes wrong in BH context), how do I get at the
> > function tracing log to find out why it panicked if the log is then
> > lost?=C2=A0=C2=A0With the serial console, at least I automatically =
capture the
> > output of kenter and co..
>=20
> But you also don't get a bunch of other useful stuff.
>=20
> btw: there is ftrace_dump_on_oops
>=20
> https://lwn.net/Articles/366796/

Cute.

How do I get at the argument values and suchlike that kenter() and co p=
rint?
I presume I would need to replace any kenter() or suchlike that printed=
 more
than just the address with a tracing hook?

David
