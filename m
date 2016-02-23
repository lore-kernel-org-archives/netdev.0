From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCHv2 04/10] rfkill: Move "state" sysfs file back to stable
Date: Tue, 23 Feb 2016 21:45:20 +0100
Message-ID: <20160223204520.GB16961@amd>
References: <1456159001-20307-1-git-send-email-jprvita@endlessm.com>
 <1456159001-20307-5-git-send-email-jprvita@endlessm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	Darren Hart <dvhart@infradead.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	platform-driver-x86@vger.kernel.org, linux-api@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux@endlessm.com,
	=?iso-8859-1?Q?Jo=E3o?= Paulo Rechi Vita
	<jprvita@endlessm.com>
To: =?iso-8859-1?Q?Jo=E3o?= Paulo Rechi Vita <jprvita@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1456159001-20307-5-git-send-email-jprvita@endlessm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon 2016-02-22 11:36:35, Jo=E3o Paulo Rechi Vita wrote:
> There is still quite a bit of code using this interface, so we can't
> just remove it. Hopefully it will be possible in the future, but sinc=
e
> its scheduled removal date is past 2 years already, we are better hav=
ing
> the documentation reflecting the current state of things.

Umm. If you think it is still obsolete (and you do), you should keep
it in place.

> -rfkill - radio frequency (RF) connector kill switch support
> -
> -For details to this subsystem look at Documentation/rfkill.txt.
> -
> -What:		/sys/class/rfkill/rfkill[0-9]+/state
> -Date:		09-Jul-2007
> -KernelVersion	v2.6.22
> -Contact:	linux-wireless@vger.kernel.org
> -Description: 	Current state of the transmitter.
> -		This file is deprecated and scheduled to be removed in
> -2014,

Change it to "and may be removed,"
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses=
/blog.html
