From: julie Sullivan <kernelmail.jms@gmail.com>
Subject: Re: 3.0.0-rc1: dmesg shows 'wlan%d' instead of 'wlan0'
Date: Mon, 6 Jun 2011 22:25:07 +0100
Message-ID: <BANLkTinEecGCZPCUeLrXu4o+hN9cKGa39w@mail.gmail.com>
References: <20110605201042.21c86763@sf>
	<BANLkTimLXr1+OLtGGXE2kzccRRG5T-G2mw@mail.gmail.com>
	<20110606203252.1854e4d7@sf>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mohammed Shafi <shafi.wireless@gmail.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sergei Trofimovich <slyich@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110606203252.1854e4d7@sf>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>
> Applied this commit on top of 3.0-rc2 and wlan%d switched to wlan0 ba=
ck.
>
> Thanks!
>
> --
>
> =A0Sergei
>

Yes, with me too:


before patch application (3.0-rc2):

[   63.837522] wlan%d: authenticate with 00:18:f6:aa:6e:25 (try 1)
[   63.843805] wlan%d: authenticated
[   63.844282] wlan%d: associate with 00:18:f6:aa:6e:25 (try 1)
[   63.846887] wlan%d: RX AssocResp from 00:18:f6:aa:6e:25
(capab=3D0x411 status=3D0 aid=3D2)
[   63.846891] wlan%d: associated

after patch application:

[   69.472955] wlan0: authenticate with 00:18:f6:aa:6e:25 (try 1)
[   69.479356] wlan0: authenticated
[   69.479863] wlan0: associate with 00:18:f6:aa:6e:25 (try 1)
[   69.482425] wlan0: RX AssocResp from 00:18:f6:aa:6e:25 (capab=3D0x41=
1
status=3D0 aid=3D2)
[   69.482428] wlan0: associated


Thanks for the pointer, Shafi.

Cheers
Julie
