From: Kay Sievers <kay.sievers@vrfy.org>
Subject: Re: network regression: cannot rename netdev twice
Date: Thu, 9 Feb 2012 00:48:56 +0100
Message-ID: <CAPXgP13j1abG-ncaGeRgTpZdPc964Q4Yz3XLk8YQm4z5Q07Hkg@mail.gmail.com>
References: <4F27120A.4040106@suse.cz> <CAPXgP12Sr2KzGJ9RA13QBOCkctb-z3O4+1uHOjANgMDDv2pxaQ@mail.gmail.com>
 <4F27C54F.1010107@suse.cz> <CAPXgP11=U_Y3LvJB2LRnXQ53y1WQQTqc0j1c7iva6ZXvF97wEw@mail.gmail.com>
 <20120204021457.GA25386@khazad-dum.debian.net> <CAPXgP12yZ74679JNwRB-pDfnjOBaxMzL2=krSDK31jM1mjXfuA@mail.gmail.com>
 <20120208020038.GE13296@khazad-dum.debian.net> <CAPXgP12ExDub9ML0=DcWRwyQP23GXDJ75jiNnw+BTXY17tEa8Q@mail.gmail.com>
 <14373.1328683324@turing-police.cc.vt.edu> <CAPXgP10-W+yeHJMENzWi7FBkYOaXw6ccMMMT=K9X2bf_Tigitw@mail.gmail.com>
 <10120.1328731572@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Henrique de Moraes Holschuh <hmh@hmh.eng.br>,
	Jiri Slaby <jslaby@suse.cz>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Greg KH <greg@kroah.com>, LKML <linux-kernel@vger.kernel.org>,
	ML netdev <netdev@vger.kernel.org>
To: Valdis.Kletnieks@vt.edu
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <10120.1328731572@turing-police.cc.vt.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 8, 2012 at 21:06,  <Valdis.Kletnieks@vt.edu> wrote:
> On Wed, 08 Feb 2012 11:57:18 +0100, Kay Sievers said:
>> On Wed, Feb 8, 2012 at 07:42, =C2=A0<Valdis.Kletnieks@vt.edu> wrote:
>
>> > Or is this sort of thing in /etc/udev/rules.d/70-persistent-net.ru=
les
>> > SUBSYSTEM=3D=3D"net", ACTION=3D=3D"add", DRIVERS=3D=3D"?*", ATTR{a=
ddress}=3D=3D"00:25:90:0b:f2:80", ATTR{type}=3D=3D"1", KERNEL=3D=3D"eth=
*", NAME=3D"eth0"
>> > what you are trying to move to, and my systems are already onboard=
 and
>> > I should just move along, nothing to see here? ;)
>>
>> Yeah, that's what we did in the past. It works fine if you never hav=
e
>> to swap names like eth0 and eth1, with need to free one of the the
>> names with a temporary rename.
>
> Well, if I had my druthers, I'd stick name=3D"net-mgt", "net-pub", an=
d "net-10g"
> in the udev rules, and not care about 1/2/3 and race conditions, beca=
use
> meaningful names are easier to not screw up (just last week found a s=
ystem that
> had eth1 and eth2 reversed in some iptables rules, wouldn't have happ=
ened if
> they were -mgt and -pub).
>
> Only thing stopping me is getting iptables to accept '-i net-10g', an=
d the
> distro /etc/sysconfig/network scripts like ifup and ifdown playing ni=
ce....
>
> So it sounds like what I want as a sysadmin is the same thing you wan=
t
> as a maintainer...

Yeah, that sounds very much like it is.

I want to push some responsibility to the admin, do less automagic,
and personally want to be less responsible for all the unintended
screw-up the automagic is causing everywhere.

Sure, the intention to keep the names like they always have been was
good, but a good intention and a broken model to deliver it, and
continue to pretend we can solve it, is the worst things we can do. :)

Kay
