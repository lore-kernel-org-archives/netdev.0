From: "=?ISO-8859-1?Q?Damien_Th=E9bault?=" <damien.thebault-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] plusb.c patched to support Belkin F5U258 USB host-to-host cable
Date: Wed, 27 Aug 2008 00:11:19 +0200
Message-ID: <9a4a382a0808261511p5fb75969r2b0f9cd218437c3f@mail.gmail.com>
References: <200802141557_MC3-1-FBB3-3DA7@compuserve.com>
	 <200802161241.02468.david-b@pacbell.net>
	 <9a4a382a0808261456me05f7b9r7f50dc69c58d25ae@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: tony_gibbs <Tony_Gibbs-Crc3fnV8OO0XQ3Lr6voeyA@public.gmane.org>,
	"NETDEV mailing list" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Linux USB mailing list" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "David Brownell" <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <9a4a382a0808261456me05f7b9r7f50dc69c58d25ae-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 26, 2008 at 23:56, Damien Th=E9bault
<damien.thebault-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> Hello,
>
> Sorry to hijack this thread, but today I bought one host-to-host USB
> cable, and it's a Belkin F5U258.
>
> On Sat, Feb 16, 2008 at 22:41, David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org> w=
rote:
>> Here's a patch with cleanups and without various encoding bugs.
>> Can you verify it still works?
>
> I applied it against my linux 2.6.26 tree, enabled plugged the two
> ends into two ports of my computer, used "ip l set usb0 up" and "ip l
> set usb1 up", started an "arping -I usb0 <some address>" and "tcpdump
> -i usb1", and I see packets.
> Then I changed the mac address of usb1, let ipv6 choose a link-local
> address and pinged it from usb0, it's working too.
> I didn't try some more advanced test as I only have one computer at
> the moment (but it should be possible to do something with iptables, =
I
> did it once)
>
>> When you test this, please enable CONFIG_USB_DEBUG and let us know
>> if those the host software still needs to do that reset ... or at
>> least, whether the diagnostic appears.
>
> The attached file is the dmesg output, I see timeouts when the
> interface is set to up (at 895 and 985), but nothing else, is this ok=
?
>

By the way, from the very beginning of this thread, the wrong email is
used for "Linux USB mailing list", it's not
"majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org", but "linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org".

So, people from linux-usb should read the previous mail in the
available archives [1][2].
(I'm sorry but I know no other way to do this)

[1] http://www.spinics.net/lists/netdev/msg55416.html
[2] http://marc.info/?l=3Dlinux-netdev&m=3D120307070602296&w=3D2

Regards,
--=20
Damien Thebault
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
