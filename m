From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility
 workaround
Date: Fri, 8 Aug 2008 00:42:31 -0400
Message-ID: <20080808004231.10dd7356.billfink@mindspring.com>
References: <47EA0DAB.7080205@securenet.de>
	<200807310939.42406.thomas.jarosch@intra2net.com>
	<20080731094436.12ec99ae@tux>
	<200807311547.57189.thomas.jarosch@intra2net.com>
	<20080806155306.72039010@tux>
	<Pine.LNX.4.64.0808071422360.4551@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q? "D=E2niel_Fraga" ?= <fragabr@gmail.com>,
	Thomas Jarosch <thomas.jarosch@intra2net.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	Sven Riedel <sr@securenet.de>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
To: =?ISO-8859-1?Q? "Ilpo_J=E4rvinen" ?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0808071422360.4551@wrl-59.cs.helsinki.fi>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 7 Aug 2008, Ilpo J=E4rvinen wrote:

> On Wed, 6 Aug 2008, D=E2niel Fraga wrote:
>=20
> > On Thu, 31 Jul 2008 15:47:55 +0200
> > Thomas Jarosch <thomas.jarosch@intra2net.com> wrote:
> >=20
> > > If your problem is really FRTO related (that what the patch is fo=
r),
> > > you could try to disable FRTO temporarily:
> >=20
> > 	Hi, the patch helped, but what's the conclusion? Is the problem
> > "solved"? Will this patch be merged in the next kernel? This thread
> > seems to be forgotten.
>=20
> ...Dave, I think we should probably put this FRTO work-around to net-=
2.6=20
> and -stable to remain somewhat robust (it's currently worked around o=
nly=20
> for newreno anyway). ...But I leave the final decision up to you.

Since you suspect the problem is being caused by a broken middlebox,
would it perhaps be a better approach to add a per-route option to
allow disabling of FRTO for the given destination.  This would be
similar to Stephen Hemminger's fix for broken middleboxes that don't
handle window scaling properly.  It seems this would be better than
modifying FRTO behavior for everyone else that is being compliant.

A question then arises is if the bogus scenario has a TCP signature
that could be used to print a warning message for the unsuspecting
user so they could then take necessary corrective action.

						-Bill
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
