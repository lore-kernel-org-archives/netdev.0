From: Bukie Mabayoje <bukiemab@gte.net>
Subject: Re: 2.4.29, e100 and a WOL packet causes keventd going mad
Date: Mon, 31 Jan 2005 13:13:35 -0800
Message-ID: <41FE9F7F.5F9E5F93@gte.net>
References: <20050130171849.GA3354@hardeman.nu> <1107143255.18167.428.camel@localhost.localdomain> <41FDB2D3.5CBD6F7D@gte.net> <20050131152431.GA14176@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: sfeldma@pobox.com, "David =?iso-8859-1?Q?H=E4rdeman?=" <david@2gen.com>,
        Michael Gernoth <simigern@stud.uni-erlangen.de>,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Marcelo Tosatti wrote:

> On Sun, Jan 30, 2005 at 08:23:47PM -0800, Bukie Mabayoje wrote:
> >
> > Scott Feldman wrote:
> >
> > > On Sun, 2005-01-30 at 09:18, David H=C3=A4rdeman wrote:
> > > > I experience the same problems as reported by Michael Gernoth whe=
n
> > > > sending a WOL-packet to computer with a e100 NIC which is already
> > > > powered on.
> > >
> > > I didn't look at the 2.4 case, but for 2.6, it seems e100 was enabl=
ing
> > > PME wakeup during probe.  PME shouldn't be enabled while the system=
 is
> > > up.  I suspect the assertion of PME while the system is up is what'=
s
> > > causing problems.  This patch moves PME wakeup enabling to either
> > > suspend or shutdown.
> > >
> > > David, would you give this patch a try?  Make sure the system still
> > > wakes from a magic packet if suspended or shut down, and doesn't ca=
use
> > > kacpid to go crazy if system is running.  If it helps for 2.6, perh=
aps
> > > someone can look into 2.4 to see if there is something similar goin=
g on
> >
> > This issue was reported on 2.4.
>
> Can any of you guys test v2.6, please?

I will be glad to test it now but I can't, I am currently doing some work=
 on 2.4. If no one has tested it in the next few days I will validate it =
then.

By the way,  do anyone have an idea how to get this functionality into 2.=
4 eepro100. The problem is that eepro100 code works on a non WOL cards.

>
>
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel"=
 in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
