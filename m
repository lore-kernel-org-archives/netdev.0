From: P@draigBrady.com
Subject: Re: 1.03Mpps on e1000
Date: Thu, 09 Dec 2004 17:19:55 +0000
Message-ID: <41B8893B.5030407@draigBrady.com>
References: <1101863399.4663.54.camel@sfeldma-mobl.dsl-verizon.net> <20041201182943.GA14470@xi.wantstofly.org> <20041201213550.GF14470@xi.wantstofly.org> <1101967983.4782.9.camel@localhost.localdomain> <20041205145051.GA647@xi.wantstofly.org> <Pine.LNX.4.58.0412051559350.29474@tux.rsn.bth.se> <Pine.LNX.4.58.0412051638290.29474@tux.rsn.bth.se> <20041208233617.GD8649@mail.com> <41B825A5.2000009@draigBrady.com> <20041209161825.GA32454@mail.com> <20041209164820.GB32454@mail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
Resent-Message-ID: <20041209214744.GC32454@mail.com>
To: Ray Lehtiniemi <rayl@mail.com>
In-Reply-To: <20041209164820.GB32454@mail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ray Lehtiniemi wrote:
> On Thu, Dec 09, 2004 at 09:18:25AM -0700, Ray Lehtiniemi wrote:
>=20
>>it is worth noting that my box has become quite unstable since
>>i started to use oprofile and pktgen together.  sshd stops responding,
>>and the network seems to go down.  not sure what is happening there...
>>this instability seems to be persisting across reboots, unfortunately...
>=20
>=20
>=20
> ok, it seems that this is related to martin's e1000 patch, and i
> just hadn't noticed it before.  rolling back the 1.2 Mpps patch
> seems to cure the problem.
>=20
> symptoms are a total freezeup of the e1000 interfaces. netstat
> -an shows a tcp connection for my ssh login to the box, with about
> 53K in the send-Q.  /proc/net/tcp is empty, however....  i can
> reproduce this at will by doing
>=20
>  # objdump -d /lib/modules/2.6.10-rc3-mp-rayl/kernel/net/core/pktgen.ko
>=20
> on that machine with the e1000-patched kernel running.
>=20
>=20
> if there's any diagnostic output i can generate that might tell
> me what's going wrong, let me know and i'll try to generate it.

can you send this to again to netdev.

thanks.

--=20
P=E1draig Brady - http://www.pixelbeat.org
--
