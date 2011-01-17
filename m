From: Geert Uytterhoeven <geert-Td1EMuHUCqxL1ZNQvxDV9g@public.gmane.org>
Subject: Re: Merging SSB and HND/AI support
Date: Mon, 17 Jan 2011 14:54:24 +0100
Message-ID: <AANLkTinwGaqg8ahGWd3+_dfhrCNTQNOfO1E-EUepFJ+C@mail.gmail.com>
References: <AANLkTi=GDcy50zsC6=Dgv1-Ty3cYK2qpx9o=q3JdXuCh@mail.gmail.com>
	<1295261783.24530.3.camel@maggie>
	<AANLkTikJcug7LUTgX_YDD4Z8ZBrdkAdLq8_Epa6TkA5f@mail.gmail.com>
	<1295265468.24530.23.camel@maggie>
	<AANLkTims0DPfG+u9qynuuj_-0WjUr1nAGLuFz3k706T-@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?Q?Michael_B=C3=BCsch?= <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>,
	linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jonas Gorski <jonas.gorski-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <AANLkTims0DPfG+u9qynuuj_-0WjUr1nAGLuFz3k706T--JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 17, 2011 at 14:43, Jonas Gorski <jonas.gorski-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wr=
ote:
> On 17 January 2011 12:57, Michael B=C3=BCsch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org> wrote:
>> Well... I don't really like the idea of running one driver and
>> subsystem implementation on completely distinct types of silicon.
>> We will end up with the same mess that broadcom ended up with in
>> their "SB" code (broadcom's SSB backplane implementation).
>> For example, in their code the driver calls pci_enable_device() and
>> related PCI functions, even if there is no PCI device at all. The ca=
lls
>> are magically re-routed to the actual SB backplane.
>> You'd have to do the same mess with SSB. Calling ssb_device_enable()
>> will mean "enable the SSB device", if the backplane is SSB, and will
>> mean "enable the HND/AI" device, if the backplane is HND/AI.

> P.S: Any suggestions for the name? Would be "ai" okay? Technically
> it's "AMBA Interconnect", but "amba" is already taken.

If it's AMBA, can it be integrated with the existing code in drivers/am=
ba/?

Gr{oetje,eeting}s,

=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-=
m68k.org

In personal conversations with technical people, I call myself a hacker=
=2E But
when I'm talking to journalists I just say "programmer" or something li=
ke that.
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0 =C2=A0=C2=A0 -- Linus Torvalds
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
