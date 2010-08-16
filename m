From: john stultz <johnstul@us.ibm.com>
Subject: Re: [PATCH 1/5] ptp: Added a brand new class driver for ptp clocks.
Date: Mon, 16 Aug 2010 12:38:06 -0700
Message-ID: <AANLkTikb3HxRSjfnDbDr3DbOJcAONahkdTiNAngoGGnk@mail.gmail.com>
References: <cover.1281956490.git.richard.cochran@omicron.at>
	<363bd749a38d0b785d8431e591bf54c38db4c2d7.1281956490.git.richard.cochran@omicron.at>
	<AANLkTik_2MKMhOuDGOmu8Kzyq-ipLe+Bxrb3FaD+Tv4U@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, devicetree-discuss@lists.ozlabs.org,
	linux-arm-kernel@lists.infradead.org,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Rodolfo Giometti <giometti@linux.it>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTik_2MKMhOuDGOmu8Kzyq-ipLe+Bxrb3FaD+Tv4U@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 16, 2010 at 12:24 PM, john stultz <johnstul@us.ibm.com> wro=
te:
> On Mon, Aug 16, 2010 at 4:17 AM, Richard Cochran
> A few comments below....
>
>> +** PTP user space API
>> +
>> + =A0 The class driver creates a character device for each registere=
d PTP
>> + =A0 clock. User space programs may control the clock using standar=
dized
>> + =A0 ioctls. A program may query, enable, configure, and disable th=
e
>> + =A0 ancillary clock features. User space can receive time stamped
>> + =A0 events via blocking read() and poll(). One shot and periodic
>> + =A0 signals may be configured via an ioctl API with semantics simi=
lar
>> + =A0 to the POSIX timer_settime() system call.
>
> As I mentioned earlier, I'm not a huge fan of the char device
> interface for abstracted PTP clocks.
> If it was just the direct hardware access, similar to RTC, which user
> apps then use as a timesource, I'd not have much of a problem. But as
> I mentioned in an earlier private mail, the abstraction level concern=
s
> me.

[snip]

> 2) As Arnd already mentioned, the chardev interface seems to duplicat=
e
> the clock_gettime/settime() and adjtimex() interfaces.

And maybe just to clarify, as I saw your response to Arnd, I'm not
suggesting using PTP clocks as clocksources for the internal
timekeeping core. Instead I'm trying to understand why PTP clocks need
the equivalent of the existing posix clocks/timer interface. Why would
only having a read-time interface not suffice?

thanks
-john
