From: Jaroslaw Fedewicz <jafd-cTM//Nd5/DKCo84Yma55WQ@public.gmane.org>
Subject: [Bug?] Machine hangs, rtl8192se possible cause
Date: Mon, 1 Aug 2011 16:26:49 +0300
Message-ID: <CAFdoEiT54o+NQKO=dAcOXgyf6GJ1E51w_H_p7PJyRmynz8Sbzg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello,

I own a Thinkpad Edge 13 (AMD, machine type 0197) laptop, which is
shipped with a Realtek 8192 SE WLAN card.

The WLAN support with this particular card was never brilliant under
Linux, first with (very) flakey drivers from Realtek which would stop
transmitting packets every so often or panic after a few hours of
usage. The in-tree drivers are better in this respect, but I'm
experiencing mysterious hangups every once in a while. The machine is
effectively dead and has to be power-cycled =E2=80=94=C2=A0no oops, no =
kernel
panic, no nothing, it just hangs and that's it.

I'm sure this is not a regression because the hangups were right there
from the start.

The last meaningful message which might be helpful was: "wait for
BIT(6) return value X" (I don't remember what X was, it was a while
ago and only once).

I don't know if there are other means to debug (netconsole over eth0?)
those hangs. The only other thing I know for sure that I can get a
week long uptime if I blacklist rtl8192se.ko from loading.

If I can provide any additional information to track the bug (or a
faulty piece of hardware?) down, please tell me. Google tells me
nobody reported this before, or it was just me feeding incorrect
keywords.

Thanks for your kind attention.

P. S. Tried netconsole before, got nothing to pinpoint the error. The
only recurring pattern I could see in it was that almost every time
the machine hanged was after ip6tables initialized, at least it was
the last message in the log.

P. P. S. I don't track netdev@ and linux-wireless@ lists, so please Cc:=
 me.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
