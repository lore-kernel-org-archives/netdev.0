From: Albert Cahalan <acahalan@gmail.com>
Subject: Re: txqueuelen has wrong units; should be time
Date: Sun, 27 Feb 2011 03:27:45 -0500
Message-ID: <AANLkTinyE10wtM_xJsufT_3s3hvti7CN+9nyqScWa6SA@mail.gmail.com>
References: <AANLkTimd5GQwtUFP2fD_An=M8ajBD8DJpzxQJezv8fB8@mail.gmail.com>
	<alpine.DEB.1.10.1102270758580.11974@uplift.swm.pp.se>
	<1298793252.8726.45.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mikael Abrahamsson <swmike@swm.pp.se>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1298793252.8726.45.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Feb 27, 2011 at 2:54 AM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le dimanche 27 f=E9vrier 2011 =E0 08:02 +0100, Mikael Abrahamsson a =E9=
crit :
>> On Sun, 27 Feb 2011, Albert Cahalan wrote:
>>
>> > Nanoseconds seems fine; it's unlikely you'd ever want
>> > more than 4.2 seconds (32-bit unsigned) of queue.
=2E..
> Problem is some machines have slow High Resolution timing services.
>
> _If_ we have a time limit, it will probably use the low resolution (a=
ka
> jiffies), unless high resolution services are cheap.

As long as that is totally internal to the kernel and never
getting exposed by some API for setting the amount, sure.

> I was thinking not having an absolute hard limit, but an EWMA based o=
ne.

The whole point is to prevent stale packets, especially to prevent
them from messing with TCP, so I really don't think so. I suppose
you do get this to some extent via early drop.
