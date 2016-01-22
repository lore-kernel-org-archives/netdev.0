From: Ian Campbell <ian.campbell@citrix.com>
Subject: Re: [Xen-devel] [PATCH 1/3] xen-netback: fix license ident used in
 MODULE_LICENSE
Date: Fri, 22 Jan 2016 14:15:47 +0000
Message-ID: <1453472147.4320.92.camel@citrix.com>
References: <1453466057-7176-1-git-send-email-wei.liu2@citrix.com>
	 <1453466057-7176-2-git-send-email-wei.liu2@citrix.com>
	 <56A22B30.3020206@citrix.com> <20160122134943.GB1691@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Xen-devel <xen-devel@lists.xenproject.org>,
	"open list:XEN NETWORK BACKEND DRIVER" <netdev@vger.kernel.org>,
	open list <linux-kernel@vger.kernel.org>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>
To: Wei Liu <wei.liu2@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:51444 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753594AbcAVOPt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2016 09:15:49 -0500
In-Reply-To: <20160122134943.GB1691@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-01-22 at 13:49 +0000, Wei Liu wrote:
> On Fri, Jan 22, 2016 at 01:14:24PM +0000, David Vrabel wrote:
> > On 22/01/16 12:34, Wei Liu wrote:
> > > The comment at the beginning of the file is the canonical source =
of
> > > licenses for this module. Currently it contains GPL and MIT licen=
se.
> > > Fix
> > > the code to reflect the reality.
> >=20
> > "The MIT license" isn't really a thing.=C2=A0=C2=A0The closest is t=
he X11
> > license[1], but this not applicable here either since the text in t=
he
> > drivers does not refer to X11 trademarks etc.
> >=20
>=20
> That was referring to the license ident string in Linux.=C2=A0=C2=A0I=
f MIT license
> isn't a thing, why would Linux have it at all?

The fact what include/linux/license.h:license_is_gpl_compatible include=
s
"Dual MIT/GPL" as an option seems to suggest that it is enough of a thi=
ng
to be validly used as the contents of a MODULE_LICENSE() thing.

It's also in=C2=A0https://opensource.org/licenses/MIT=C2=A0, the fact t=
hat it might
be confused for other licenses used by MIT notwithstanding.

=46WIW=C2=A0https://en.wikipedia.org/wiki/MIT_License=C2=A0seems to thi=
nk that the
wording most commonly called the "MIT License" might be the "Expat
license", rather than the "X11 License" which is similar but different.

Ian.
