From: Luis Henriques <luis.henriques@canonical.com>
Subject: Re: [PATCH stable-3.2 stable-3.12] net: fix checksum check in
 skb_copy_and_csum_datagram_iovec()
Date: Fri, 15 Jan 2016 18:16:36 +0000
Message-ID: <20160115181636.GB1980@charon.olymp>
References: <20151228140157.6F592A0C7D@unicorn.suse.cz>
 <568BF0FD.4010208@suse.cz>
 <1452012008.2768.82.camel@decadent.org.uk>
 <1452682920.7020.32.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Slaby <jslaby@suse.cz>, Michal Kubecek <mkubecek@suse.cz>,
	stable@vger.kernel.org, Sabrina Dubroca <sd@queasysnail.net>,
	netdev@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1452682920.7020.32.camel@decadent.org.uk>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 13, 2016 at 11:02:00AM +0000, Ben Hutchings wrote:
> On Tue, 2016-01-05 at 16:40 +0000, Ben Hutchings wrote:
> > On Tue, 2016-01-05 at 17:36 +0100, Jiri Slaby wrote:
> > > On 12/28/2015, 03:01 PM, Michal Kubecek wrote:
> > > > Recent fix "net: add length argument to
> > > > skb_copy_and_csum_datagram_iovec" added to some pre-3.19 stable
> > > > branches, namely
> > > >=20
> > > > =A0 stable-3.2.y: commit 127500d724f8
> > > > =A0 stable-3.12.y: commit 3e1ac3aafbd0
> > >=20
> > > Applied this fix to 3.12. Thanks!
> > [...]
> >=20
> > You don't want this, you want Eric's fix (commit 197c949e7, "udp:
> > properly support MSG_PEEK with truncated buffers") although that's =
not
> > upstream yet.
>=20
> It's now upstream as commit 197c949e7798fbf28cfadc69d9ca0c2abbf93191.
>=20

Thanks, I'm queuing it for the 3.16 kernel as well.

Cheers,
--
Lu=EDs

> Ben.
>=20
> --=20
> Ben Hutchings
> Unix is many things to many people,
> but it's never been everything to anybody.
