From: =?UTF-8?B?TWljaGFlbCBCw7xzY2g=?= <mb@bu3sch.de>
Subject: Re: [PATCH 0/3] b43: logging cleanups
Date: Fri, 25 Jun 2010 15:28:04 +0200
Message-ID: <4C24AEE4.4090700@bu3sch.de>
References: <cover.1276988387.git.joe@perches.com>	 <20100624185339.GC2368@tuxdriver.com> <1277408432.1654.80.camel@Joe-Laptop.home> (sfid-20100624_214041_280758_2585CA6E)
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Stefano Brivio <stefano.brivio@polimi.it>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Larry.Finger@lwfinger.net,
	zajec5@gmail.com
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1277408432.1654.80.camel@Joe-Laptop.home> (sfid-20100624_214041_280758_2585CA6E)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/24/2010 09:40 PM, Joe Perches wrote:
> On Thu, 2010-06-24 at 14:53 -0400, John W. Linville wrote:
>> On Sat, Jun 19, 2010 at 04:30:08PM -0700, Joe Perches wrote:
>>> Just some small cleanups
>>> Joe Perches (3):
>>>    drivers/net/wireless/b43: Use local ratelimit_state
>>>    drivers/net/wireless/b43: Logging cleanups
>>>    drivers/net/wireless/b43: Rename b43_debug to b43_debugging
>> Any of the b43 guys want to express an opinion on these?

The cleanups, well, exchange one name for the other. I don't have a
strong opinion on one or the other. So in the end I don't see why
that stuff should be renamed. However, in the end I really do not care.

I'm not sure why we need an additional ratelimit here. Is it a policy
that every kernel driver should have local ratelimiting? If not, why
do you think b43 needs its own ratelimiting? Note that b43 does not
output a single line to dmesg in normal operation, after init has
finished (and ratelimit is disabled in init).

> Stefano, are you active here?
> Your last ack for b43 was Feb 2008.
> There have been 400+ commits to b43 without your ack.
>
> Should your name be moved from MAINTAINERS to CREDITS?
>
> $ ./scripts/get_maintainer.pl --rolestats -f drivers/net/wireless/b43=
/
> Stefano Brivio<stefano.brivio@polimi.it>  (maintainer:B43 WIRELESS DR=
IVER)
> "John W. Linville"<linville@tuxdriver.com>  (maintainer:NETWORKING [W=
IREL...,commit_signer:204/240=3D85%)
> "Rafa=C5=82 Mi=C5=82ecki"<zajec5@gmail.com>  (commit_signer:83/240=3D=
35%)
> "G=C3=A1bor Stefanik"<netrolller.3d@gmail.com>  (commit_signer:44/240=
=3D18%)
> Michael Buesch<mb@bu3sch.de>  (commit_signer:39/240=3D16%)
> Larry Finger<Larry.Finger@lwfinger.net>  (commit_signer:13/240=3D5%)
> linux-wireless@vger.kernel.org (open list:B43 WIRELESS DRIVER)
> netdev@vger.kernel.org (open list:NETWORKING DRIVERS)
> linux-kernel@vger.kernel.org (open list)

I think these statistics are almost worthless for b43.

--=20
Greetings Michael.
