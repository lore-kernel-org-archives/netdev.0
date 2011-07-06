From: Chuck Hast <wchast@gmail.com>
Subject: Re: instant oops with AF_ROSE
Date: Wed, 6 Jul 2011 07:42:32 -0400
Message-ID: <CADNfBV_i6st5PD_7bJta2rUwGjzt6eBckeeEGTt4osjr_P_R+g@mail.gmail.com>
References: <20110706.035735.1271031398642349034.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, ralf@linux-mips.org,
	linux-hams@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <20110706.035735.1271031398642349034.davem@davemloft.net>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 6, 2011 at 06:57, David Miller <davem@davemloft.net> wrote:
>
> The support for ipv4 over rose devices has been broken for as long as
> the code has existed (I went back to 2.0.x just to make sure). =A0Try
> this:
>
> modprobe rose
> ip link set rose0 up
> ip addr add 11.0.0.3/8 dev rose0
> ping -b 11.255.255.255
>
> That should crash your box pretty well.
>
----- Text cut for bandwidth reduction-----------

It has been a while, and we were (still are I just am not active)  usin=
g FPAC
we have run a lot of IP through it, and never seemed to have a issue, b=
ut
perhaps this is not quite in that area.

I  am sure Bernard will see this and pitch in with more info. I am
just trying to
figure out if we are taking two different pieces here.

Here in FL I have ran both NetRom and IP over ROSE through FPAC boxes
with no issues that I can remember. FPAC is a wrapper around the rose p=
iece.
We probably have people still doing IP inside ROSE through FPAC boxes a=
round
the state, not sure who or where, but it would not be a surprise to me =
because
some use SMTP between their BBS devices.


Bernard, any comments?
--=20

Chuck Hast =A0-- KP4DJT --
To paraphrase my flight instructor;
"the only dumb question is the one you DID NOT ask resulting in my goin=
g
out and having to identify your bits and pieces in the midst of torn
and twisted metal."
---
Home web site:
www.wchast.com

ZoneMinder Demo and test site
www.wchast.com/zm
Login =3D guest
pwd=A0 =A0=3D guest
--
To unsubscribe from this list: send the line "unsubscribe linux-hams" i=
n
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
