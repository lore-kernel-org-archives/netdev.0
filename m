From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC 1/2] net: Introduce recvmmsg socket syscall
Date: Thu, 4 Jun 2009 06:47:41 -0400
Message-ID: <20090604104741.GA7471@hmsreliant.think-freely.org>
References: <20090520230652.GB5956@ghostprotocols.net> <20090522200611.GB967@hmsreliant.think-freely.org> <c0a09e5c0906031844v7e88572ewdab7b9c4e1295c0c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Chris Van Hoof <vanhoof@redhat.com>,
	Clark Williams <williams@redhat.com>
To: Andrew Grover <andy.grover@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:41378 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756501AbZFDKru (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2009 06:47:50 -0400
Content-Disposition: inline
In-Reply-To: <c0a09e5c0906031844v7e88572ewdab7b9c4e1295c0c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 03, 2009 at 06:44:22PM -0700, Andrew Grover wrote:
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
>=20
> Regards -- Andy
>=20

Its entirely possible it was just something he talked about on IRC, I j=
ust
brought it up because of the overlap.
Neil

