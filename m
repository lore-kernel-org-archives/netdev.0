From: Matthias Fruehauf <mfrueh@suse.de>
Subject: Re: Linux kernel updates and ip_crossover patch
Date: Thu, 30 Oct 2003 14:16:29 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031030131628.GL17431@suse.de>
References: <OF5B9BCA99.0441857B-ON65256DCF.004761FF-65256DCF.004828A5@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: Olaf Hering <olh@suse.de>, Anil K Prasad <aprasad@in.ibm.com>,
        Kaena Freitas <kaena@us.ibm.com>, olaf@suse.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mehulkumar J Patel <mehul.patel@in.ibm.com>
Content-Disposition: inline
In-Reply-To: <OF5B9BCA99.0441857B-ON65256DCF.004761FF-65256DCF.004828A5@in.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Oct 30, Mehulkumar J Patel wrote:

>=20
> Hello All,
>=20
> Any update on this.
>=20
> Basically we need IP CROSSOVER patch to be part of pseries kernel.

Well, I am not completly sure what we are talking about here ... ;-) The
usuall way if someone wants features to become part of the kernel is via
the community, in this case via the network guys as Olaf suggested or if
it is a plattform specific thing via the plattform maintainer, which is
David Engebretsen <engebret@us.ibm.com> for example for PPC at IBM.

In case that there is for some reason no solution going this path, IBM
has the possibility to request features from SuSE via the brands and via
the LTC. This is organized by Mark VanderWiele <markv@us.ibm.com>.

To be more specific: For 2.4 kernel the door is allready closed since
some weeks. In case you would like to see this patch in an upcoming SLES
9 and a 2.6 kernel, get in contact with Dave and Mark.

Hope this helps for the moment.


> best regards,
> Mehul.
>=20

Best regards,

Matthias Fr=FChauf


>=20
>  Olaf Hering                                                           =
       =20
>  <olh@suse.de>         To:        Kaena Freitas <kaena@us.ibm.com>, Meh=
ulkumar=20
>                J Patel/India/IBM@IBMIN                                 =
       =20
>  29/09/2003            cc:        Mehulkumar J Patel/India/IBM@IBMIN, M=
atthias=20
>  16:40         Fruehauf <mfrueh@suse.de>, olaf@suse.de, Anil K Prasad/I=
ndia/  =20
>                IBM@IBMIN, Daljeet Maini/India/IBM@IBMIN                =
       =20
>                        Subject:        Re: Linux kernel updates and    =
       =20
>                ip_crossover patch                                      =
       =20
>                                                                        =
       =20
>                                                                        =
       =20
>=20
>=20
>=20
>  On Wed, Sep 24, Kaena Freitas wrote:
>=20
> >
> >
> >
> >
> > Hello Mehul -
> >
> > Sorry it has taken me a while to respond. We do not keep any code in =
CMVC.
> > All code we get from SuSE is on the ftp3 site along with all the sour=
ce
> > RPMs. We do have internel CVS trees, but there is no guarantee that t=
hose
> > trees are current with the code we get from SuSE which is what your t=
eam
> > should be testing.
> >
> > As for the htx patch you've provided, I have copied SuSE on this emai=
l to
> > get their comments if it can be part of their distribution.
>=20
> Good morning,
>=20
> did you sent the patch to netdev@oss.sgi.com?
> What opinion have the network and iptables maintainers about this featu=
re?
>=20
>=20
> > (See attached file: hxecom_patch)forgot to attach the patch.
> >
> >
> > e-mail: mehul.patel@in.ibm.com
> > IBM Global Services
> > Bangalore, India.
> > Tel: 091-80-5094160
> >
> >
> >
> >                                                                      =
       =20
>                                     =20
> >                       Mehulkumar J                                   =
      =20
>                                     =20
> >                       Patel                    To:       Kaena Freita=
s/Austin
> /IBM                                 =20
> >                                                cc:       Anil K Prasa=
d/India/
> IBM@IBMIN, Daljeet                   =20
> >                       23/09/2003 18:38          Maini/India/IBM@IBMIN=
       =20
>                                     =20
> >                       Please respond to        From:     Mehulkumar J=
 Patel/
> India/IBM@IBMIN                       =20
> >                                                Subject:  Linux kernel=
 updates
> and ip_crossover patch             =20
> >                                                                      =
       =20
>                                     =20
> >                                                                      =
       =20
>                                     =20
> >                                                                      =
       =20
>                                     =20
> >
> >
> >
> > Hi,
> >
> > We are HTX Team.
> > We get affected by changes in Linux kernel in a way where we have to =
update
> > our build environment
> > continuously. As of now we are doing so manually. But considering the
> > effort we are thinking of making
> > it automated.
> >
> > Can you please tell us if there is a fixed place from where we can sy=
nc
> > Linux kernel sources through
> > scripts. Or do you put Linux kernel sources in cmvc or any other vers=
ion
> > control system.
> >
> > Also, we have an exerciser named "hxecom" which requires an external =
patch,
> > ip_crossover for hxecom
> >  to work in single system test.
> > This patch helps us in sending packets destined to IP address on the =
same
> > machine without looping
> > back at IP layer. Packet actually goes out to hardware and thus we ar=
e able
> > to stress network cards.
> > For this patch to work, kernel should have been compiled with netfilt=
er.
> > If netfilter is not enabled and ip_crossover patch is not applied, we=
 end
> > up recompiling the whole
> > stuff and need to copy kernel and /lib/modules on all the test machin=
es,
> > which is bit ugly.
> > Can you please include these two request from us in all p-series kern=
els ?
> >
> > I am attaching the patch here.
> >
> > best regards,
> > Mehul.
> > e-mail: mehul.patel@in.ibm.com
> > IBM Global Services
> > Bangalore, India.
> > Tel: 091-80-5094160
> >
> >
> >
>=20
>=20
>=20
> --
> USB is for mice, FireWire is for men!
>=20
> sUse lINUX ag, n=DCRNBERG
>=20
>=20

--=20
	Matthias Fr=FChauf

	Member of the spicy SuSE Linux PPC Team
------------------------------------------------------------
SuSE AG,                  Tel:   +49-911-74053-658
Deutschherrnstr. 15-19,   Fax:   +49-911-74053-483
90429 Nuernberg           Germany

               --- Peace, Love and Linux ---
