From: Wolfgang Walter <linux@stwm.de>
Subject: Re: Soft lockup issue in Linux 4.1.9
Date: Fri, 02 Oct 2015 21:25:31 +0200
Message-ID: <4566854.f3tDMKHNpU@h2o.as.studentenwerk.mhn.de>
References: <1443650383.13282.10.camel@daevel.fr> <560E2994.5020400@tomt.net> <560E2F7C.4040102@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andre Tomt <andre@tomt.net>, Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	LKML <linux-kernel@vger.kernel.org>, stable@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Holger =?ISO-8859-1?Q?Hoffst=E4tte?=
	<holger.hoffstaette@googlemail.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <560E2F7C.4040102@googlemail.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Freitag, 2. Oktober 2015, 09:17:16 schrieb Holger Hoffst=E4tte:
> On 10/02/15 08:52, Andre Tomt wrote:
> > On 01. okt. 2015 13:52, Eric Dumazet wrote:
> >> On Thu, Oct 1, 2015 at 4:43 AM, Holger Hoffst=E4tte
> >>=20
> >> <holger.hoffstaette@googlemail.com> wrote:
> >>> On 10/01/15 13:29, Eric Dumazet wrote:
> >>>> commit 83fccfc3940c4a2db90fd7e7079f5b465cd8c6af
> >>>> Author: Eric Dumazet <edumazet@google.com>
> >>>> Date:   Thu Aug 13 15:44:51 2015 -0700
> >>>>=20
> >>>>      inet: fix potential deadlock in reqsk_queue_unlink()
> >=20
> > <snip>
> >=20
> >>> Whohoo! It applies/builds cleanly to 4.1.10-rc1 and is running as
> >>> we speak. Let's hope that this fixes the lockups.
> >>=20
> >> It definitely should help !
> >>=20
> >> David, since patch is not yet seen on
> >> http://patchwork.ozlabs.org/bundle/davem/stable/?state=3D*
> >> could you please add it to your queue ?
> >=20
> > Seems to fix it for me as well. 3 systems have been running varying
> > types of production-like loads with it for 14+ hours without hangin=
g.
>=20
> Just got up, and yes - my systems survived the night as well, no issu=
es.
>=20
> Greg, any chance you can drop this into the pending 4.1.10? Otherwise=
 people
> will get another broken release.
>=20

=46ixes the problem here, too.

Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
