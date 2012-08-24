From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC PATCH bridge 0/5] Add basic VLAN support to bridges
Date: Fri, 24 Aug 2012 13:44:10 -0700
Message-ID: <20120824134410.75827e0d@nehalam.linuxnetplumber.net>
References: <1345750195-31598-1-git-send-email-vyasevic@redhat.com>
	<50369A99.2070405@gmail.com>
	<5036EC52.9090406@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nicolas de =?ISO-8859-1?B?UGVzbG/8YW4=?=
	<nicolas.2p.debian@gmail.com>, netdev@vger.kernel.org
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:58713 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933305Ab2HXUoa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 16:44:30 -0400
In-Reply-To: <5036EC52.9090406@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 23 Aug 2012 22:52:02 -0400
Vlad Yasevich <vyasevic@redhat.com> wrote:

> On 08/23/2012 05:03 PM, Nicolas de Peslo=FCan wrote:
> > Le 23/08/2012 21:29, Vlad Yasevich a =E9crit :
> >> This series of patches provides an ability to add VLAN IDs to the =
bridge
> >> ports.  This is similar to what can be found in most switches.  Th=
e
> >> bridge
> >> port may have any number of VLANs added to it including vlan 0 for
> >> untagged
> >> traffic.  When vlans are added to the port, only traffic tagged wi=
th
> >> particular
> >> vlan will forwarded over this port.  Additionally, vlan ids are ad=
ded
> >> to FDB
> >> entries and become part of the lookup.  This way we correctly iden=
tify
> >> the FDB
> >> entry.
> >>
> >> There are still pieces missing.  I don't yet support adding a stat=
ic
> >> fdb entry
> >> with a particular vlan.  There is no netlink support for carrying =
a
> >> vlan id.
> >>
> >> I'd like to hear thoughts of whether this is usufull and something=
 we
> >> should
> >> persue.
> >>
> >
> > Do you think this might allow for per VLAN spanning tree (having po=
rts
> > in forwarding state or blocking state depending on the VLAN) in the=
 future?
> >
> >      Nicolas.
>=20
> sure, why not.

The vlan map table would be helpful, but the Spanning Tree implementati=
on
doesn't have a clue about what it means.
