From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [RFC 1/2] net: Introduce recvmmsg socket syscall
Date: Wed, 3 Jun 2009 22:46:23 -0300
Message-ID: <20090604014622.GI7805@ghostprotocols.net>
References: <20090520230652.GB5956@ghostprotocols.net> <20090522200611.GB967@hmsreliant.think-freely.org> <c0a09e5c0906031844v7e88572ewdab7b9c4e1295c0c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Chris Van Hoof <vanhoof@redhat.com>,
	Clark Williams <williams@redhat.com>
To: Andrew Grover <andy.grover@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:47956 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751186AbZFDBqb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jun 2009 21:46:31 -0400
Content-Disposition: inline
In-Reply-To: <c0a09e5c0906031844v7e88572ewdab7b9c4e1295c0c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Wed, Jun 03, 2009 at 06:44:22PM -0700, Andrew Grover escreveu:
> On Fri, May 22, 2009 at 1:06 PM, Neil Horman <nhorman@tuxdriver.com> =
wrote:
> > Not to throw more questions into the mix again, but didn't Ingo wri=
te a
> > batching syscall a while back, which let you issue several syscalls=
 in one trap
> > to kernel space? =A0I understand that your approach has some effici=
ency gains over
> > that, but did that ever get accepted upstream? =A0Is the overlap th=
ere sufficient
> > to make this approach redundant? =A0Or are the gains in performance=
 here
> > sufficient to warrant this new call?
>=20
> I couldn't find this via Google or any posts to LKML by Ingo on this?
>=20
> I'm very interested in multiple send/recvmsg support. So, it's
> definitely going to happen? :-)

I got sidetracked with some other activities, and was waiting for more
comments and reports from some testers, but will be back to implement a
v2 patch soon.

- Arnaldo
