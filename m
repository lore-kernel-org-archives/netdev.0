From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC PATCH bridge 0/5] Add basic VLAN support to bridges
Date: Thu, 23 Aug 2012 14:12:22 -0700
Message-ID: <20120823141222.62ef213a@nehalam.linuxnetplumber.net>
References: <1345750195-31598-1-git-send-email-vyasevic@redhat.com>
	<50369A99.2070405@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org
To: Nicolas de =?ISO-8859-1?B?UGVzbG/8YW4=?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36016 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934412Ab2HWVMm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 17:12:42 -0400
In-Reply-To: <50369A99.2070405@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 23 Aug 2012 23:03:21 +0200
Nicolas de Peslo=FCan <nicolas.2p.debian@gmail.com> wrote:

> Le 23/08/2012 21:29, Vlad Yasevich a =E9crit :
> > This series of patches provides an ability to add VLAN IDs to the b=
ridge
> > ports.  This is similar to what can be found in most switches.  The=
 bridge
> > port may have any number of VLANs added to it including vlan 0 for =
untagged
> > traffic.  When vlans are added to the port, only traffic tagged wit=
h particular
> > vlan will forwarded over this port.  Additionally, vlan ids are add=
ed to FDB
> > entries and become part of the lookup.  This way we correctly ident=
ify the FDB
> > entry.
> >
> > There are still pieces missing.  I don't yet support adding a stati=
c fdb entry
> > with a particular vlan.  There is no netlink support for carrying a=
 vlan id.
> >
> > I'd like to hear thoughts of whether this is usufull and something =
we should
> > persue.
> >
>=20
> Do you think this might allow for per VLAN spanning tree (having port=
s in forwarding state or=20
> blocking state depending on the VLAN) in the future?
>=20
> 	Nicolas.

Completely different problem
