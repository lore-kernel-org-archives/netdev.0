From: Roger Luethi <rl@hellgate.ch>
Subject: Re: [PATCH] via-rhine: hardware VLAN support
Date: Tue, 9 Nov 2010 07:18:32 +0100
Message-ID: <20101109061831.GA8730@core.hellgate.ch>
References: <20101105104303.GA8325@core.hellgate.ch>
 <AANLkTikUe9DR2QTU+72Q8vmGnDyvUtSm_wwCpGEq-M4s@mail.gmail.com>
 <20101108162132.GA32728@core.hellgate.ch>
 <AANLkTim40QH2AWz8YtW_y3=WjEU0_Rom9-CPFj-O5MCt@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail13.bluewin.ch ([195.186.18.62]:14072 "EHLO
	mail13.bluewin.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752558Ab0KIGSf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Nov 2010 01:18:35 -0500
Content-Disposition: inline
In-Reply-To: <AANLkTim40QH2AWz8YtW_y3=WjEU0_Rom9-CPFj-O5MCt@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 08 Nov 2010 12:53:57 -0800, Jesse Gross wrote:
> On Mon, Nov 8, 2010 at 8:21 AM, Roger Luethi <rl@hellgate.ch> wrote:
> > On Fri, 05 Nov 2010 11:31:56 -0700, Jesse Gross wrote:
> >> On Fri, Nov 5, 2010 at 3:43 AM, Roger Luethi <rl@hellgate.ch> wrot=
e:
> >> > This patch adds VLAN hardware support for Rhine chips.
> >>
> >> This uses the old interfaces for vlan acceleration. =A0We're worki=
ng to
> >> switch drivers over to use the new methods and the old ones will b=
e
> >> going away in the future. =A0It would be great if we can avoid add=
ing
> >> more code that uses those interfaces.
> >
> > Can you point me to a driver that has been switched to use the new =
methods
> > already? Is there some other form of documentation?
>=20
> bnx2 is an example of a driver that has been converted.  The commit
> that actually made the change was
> 7d0fd2117e3d0550d7987b3aff2bfbc0244cf7c6, which should highlight the
> differences.  A key point is that drivers should no longer reference
> vlan groups at all.

Thank you. I will take a look and submit a revised patch.
