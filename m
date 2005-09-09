From: Bernd Schubert <bernd.schubert@pci.uni-heidelberg.de>
Subject: Re: skge: reboot on sysfs resource0 access
Date: Fri, 9 Sep 2005 20:09:40 +0200
Message-ID: <200509092009.41497.bernd.schubert@pci.uni-heidelberg.de>
References: <200509091938.18079.bernd.schubert@pci.uni-heidelberg.de> <20050909110153.5a2e2e90@localhost.localdomain>
Reply-To: bernd-schubert@gmx.de
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050909110153.5a2e2e90@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Friday 09 September 2005 20:01, you wrote:
> On Fri, 9 Sep 2005 19:38:17 +0200
>
> Bernd Schubert <bernd.schubert@pci.uni-heidelberg.de> wrote:
> > Hello,
> >
> > today we tried 2.6.13 on our server and also tried to use the skge
> > driver. Well, in principle it works fine, until I became curious abou=
t
> > the sysfs values. Stupid me, I was using the midnight commander to re=
ad
> > the values. When I opened
> > "/sys/bus/pci/drivers/skge/0000:01:01.0/resource0", the system
> > immediately rebooted. After the reboot we tested using cat to the
> > resource0 file, which gave an input/output error. Using again the mc,=
 the
> > system again immediately rebooted.
> > Well, I guess I better don't use the midnight commander in the future=
,
> > but somehow I think it shouldn't cause the system to reboot, should i=
t?
> > Is the i/o error of cat supposed to happen?
>
> Don't do that!  resource0 is the pci space for the card and
> reading it directly accesses the memory mapped space. The
> register is sparse, and some places are unaccessable.
> Accessing non-existent memory will cause system to hang and if you
> are lucky a timeout and reboot.
>
> Sorry, this is not a driver bug.

Thanks, I better also won't read the resource values of the other pci-dev=
ices.=20
And I think I will search for some documentation of sysfs to know in the=20
future which values one should read and which not.

Thanks again,
	Bernd

--=20
Bernd Schubert
Physikalisch Chemisches Institut / Theoretische Chemie
Universit=E4t Heidelberg
INF 229
69120 Heidelberg
e-mail: bernd.schubert@pci.uni-heidelberg.de
