From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [Bug?] Machine hangs, rtl8192se possible cause
Date: Mon, 01 Aug 2011 10:30:27 -0500
Message-ID: <4E36C693.6000705@lwfinger.net>
References: <CAFdoEiT54o+NQKO=dAcOXgyf6GJ1E51w_H_p7PJyRmynz8Sbzg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jaroslaw Fedewicz <jafd-cTM//Nd5/DKCo84Yma55WQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAFdoEiT54o+NQKO=dAcOXgyf6GJ1E51w_H_p7PJyRmynz8Sbzg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 08/01/2011 08:26 AM, Jaroslaw Fedewicz wrote:
> Hello,
>
> I own a Thinkpad Edge 13 (AMD, machine type 0197) laptop, which is
> shipped with a Realtek 8192 SE WLAN card.
>
> The WLAN support with this particular card was never brilliant under
> Linux, first with (very) flakey drivers from Realtek which would stop
> transmitting packets every so often or panic after a few hours of
> usage. The in-tree drivers are better in this respect, but I'm
> experiencing mysterious hangups every once in a while. The machine is
> effectively dead and has to be power-cycled =E2=80=94 no oops, no ker=
nel
> panic, no nothing, it just hangs and that's it.
>
> I'm sure this is not a regression because the hangups were right ther=
e
> from the start.
>
> The last meaningful message which might be helpful was: "wait for
> BIT(6) return value X" (I don't remember what X was, it was a while
> ago and only once).
>
> I don't know if there are other means to debug (netconsole over eth0?=
)
> those hangs. The only other thing I know for sure that I can get a
> week long uptime if I blacklist rtl8192se.ko from loading.
>
> If I can provide any additional information to track the bug (or a
> faulty piece of hardware?) down, please tell me. Google tells me
> nobody reported this before, or it was just me feeding incorrect
> keywords.
>
> Thanks for your kind attention.
>
> P. S. Tried netconsole before, got nothing to pinpoint the error. The
> only recurring pattern I could see in it was that almost every time
> the machine hanged was after ip6tables initialized, at least it was
> the last message in the log.
>
> P. P. S. I don't track netdev@ and linux-wireless@ lists, so please C=
c: me.

What kernel are you using? The only problems I've had were some kernel =
panics=20
due to improper handling of memory allocation failures with the receive=
 skb's,=20
but they have been fixed.

It can be difficult to use netconsole to debug problems with wireless d=
evices.

As you prevent rtl8192se from loading automatically, the logging consol=
e may=20
provide some clues. Use the following command to load the driver:

sleep 10 ; modprobe rtl8192se

During the 10 second sleep, use CTRL-ALT-F10 to switch consoles and see=
 if any=20
messages appear.

Please use 'lspci -nn' to determine which version of the card you have.

Thanks,

Larry
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
