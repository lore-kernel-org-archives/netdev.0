From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH, resubmit] ax88179_178a: ASIX AX88179_178A USB 3.0/2.0 to gigabit ethernet adapter driver
Date: Mon, 28 Jan 2013 15:24:34 +0100
Message-ID: <878v7dpeql.fsf@nemi.mork.no>
References: <1358908337-13841-1-git-send-email-freddy@asix.com.tw>
	<20130127001347.584711b2@xenia> <87zjztptez.fsf@nemi.mork.no>
	<010f01cdfd5c$768d4240$63a7c6c0$@asix.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "'Michael Leun'" <lkml20130126-yS7QfQBdiAdyjo5WHAzKoQ@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <louis-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>,
	<davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <Support-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>
To: "Freddy" <freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <010f01cdfd5c$768d4240$63a7c6c0$@asix.com.tw>
	(freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org's message of "Mon, 28 Jan 2013 21:36:20 +0800")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

"Freddy" <freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org> writes:

> Bj=C3=B8rn, I am trying to reproduce the issue mentioned by Michael a=
nd I
> have a question about submitting this driver.
>
> Should I merge this driver into asix_devices.c and asix_common.c even
> through the usb command, tx_fixup, and rx_fixup functions are totally
> different?

This is only my personal opinion and does not count as more than that,
but I would have tried to identify as many common parts as possible in
these drivers and reuse as much code as possible instead of creating
slightly different copies.  That does not mean that there shouldn't be
anything different.  If the framing is completely different, then it
does of course not make any sense to share tx_fixup and rx_fixup.  But
my impression from looking briefly on these drivers is that a lof of th=
e
code is very similar. I could of course be wrong...

Please note that modifying asix_common.c in this process is perfectly O=
K
if that is necessary.  The only requirement is that you don't break
anything that used to work.


Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
