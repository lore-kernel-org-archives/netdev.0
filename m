From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] iproute2: support xfrm upper protocol gre key
Date: Tue, 23 Nov 2010 10:54:18 -0800
Message-ID: <20101123105418.65072de8@nehalam>
References: <1290524559-22086-1-git-send-email-timo.teras@iki.fi>
	<20101123082404.5b8ad019@nehalam>
	<4CEBEF7C.2060806@iki.fi>
	<20101123101302.54a9e4be@nehalam>
	<4CEC0A42.60209@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Timo =?ISO-8859-1?B?VGVy5HM=?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:45825 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754235Ab0KWSyj convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Nov 2010 13:54:39 -0500
In-Reply-To: <4CEC0A42.60209@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 23 Nov 2010 20:38:58 +0200
Timo Ter=E4s <timo.teras@iki.fi> wrote:

> On 11/23/2010 08:13 PM, Stephen Hemminger wrote:
> > On Tue, 23 Nov 2010 18:44:44 +0200
> > Timo Ter=E4s <timo.teras@iki.fi> wrote:
> >> On 11/23/2010 06:24 PM, Stephen Hemminger wrote:
> >>> The GRE key is not really an IPv4 address. Why should the utiliti=
es
> >>> use IPv4 address manipulation to format/scan it.  It makes more s=
ense
> >>> to me to just use u32 an do the necessary ntohl.
> >>
> >> This is pretty much how iptunnel.c does it, so I copied the code. =
Would
> >> you prefer to format it as single u32 number? Or use something els=
e for
> >> formatting it similar to IPv4?
> >>
> >> In either case, we should change iptunnel.c to match ipxfrm.c. It'=
ll be
> >> easier if both parts handling the gre key treat it equivalently.
> >>
> >> I think Cisco does indeed treat it as u32 number in the configurat=
ions.
> >> So I'm okay updating this patch, and fixing iptunnel.c side too. W=
e
> >> might still want to keep the parsing of ipv4 format to keep backwa=
rds
> >> compatibility.
> >=20
> > My preference would be to take both dotted quad and a single
> > number.
>=20
> And I assume that when dumping stuff, it should be output as single
> number. Or make that configurable with some switch?
>=20
> I'll refresh my patch and fix iptunnel.c output tomorrow.

Just show it as a decimal number. That is what Cisco and Juniper do.

--=20
