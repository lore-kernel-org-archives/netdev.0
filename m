From: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Is this 32-bit NCM?
Date: Sun, 30 Nov 2014 02:13:44 +0100 (CET)
Message-ID: <alpine.LNX.2.03.1411300202310.4742@gmail.com>
References: <alpine.LNX.2.03.1411262250160.4356@gmail.com> <87ppc957h1.fsf@nemi.mork.no> <alpine.LNX.2.03.1411271037050.9464@gmail.com> <874mtl55ar.fsf@nemi.mork.no> <CAPChA0cLuvRpYTYuFoi3bewqASgf_oZHSz5yQQ8JYm96dZ4-TQ@mail.gmail.com> <54781523.6030600@audiocodes.com>
 <alpine.LNX.2.03.1411280923230.3997@gmail.com> <54783443.50700@audiocodes.com> <alpine.LNX.2.03.1411280944200.4040@gmail.com> <54783A1D.3090607@audiocodes.com> <alpine.LNX.2.03.1411281014450.4101@gmail.com> <54783F84.20105@audiocodes.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Alex Strizhevsky <alexxst-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	=?ISO-8859-15?Q?Bj=F8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>,
	Midge Shaojun Tan <ShaojunMidge.Tan-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>,
	"youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Eli Britstein <Eli.Britstein-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>
To: Kevin Zhu <Mingying.Zhu-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <54783F84.20105-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi guys.
Sorry for the late our but ... I was trying to figure out something new about 
this dongle.
I also searched for it in my city shops without finding it actually.
But then I came back and ... tried to look at some things.

Alex, Kevin: in the Windows USB captures you sent me (and that I sent on the 
List), I can notiche something very strange.
with a shell on a computer connected to a test device I can see the following:
at+gmr
21.286.03.01.209
OK
and so why in the Windows sniff the dongle answers to the same question 
something like
23.128.00.00.00
?
Alex - was it the same dongle?
Kevin or anyone: can you use putty to interact with the dongle under Windows 
and type some commands, like:
at+gmr
and other similar commands?
If the dongle reports different firmware versions under Linux and Windows, then 
guys... we need to figure out the Windows switch message.
Overmore - in the device installation sh*t, you can see there is a firmware 
updater... Why?

Alex: I used the
at^reset
command to get the modem back to normal state once; and so it restored the 
nvram to default or something.
If you reconnect it to windows ... i hope it gets re-setup as before.
But - nothing harmful to the device, only to it's settings, sorry.
I restored the relevant settings and it connects again, but no dhcp. But - be 
peaceful: other modems out there seems to not get dhcp anyway.
this is the state the modem arrives when you buy it, so windows should know 
Wwhat To Say To The Modem (TM).
Another thing - note that:
[14170.048693] cdc_ncm 1-2:1.2: GET_MAX_DATAGRAM_SIZE failed

Any ideas, comments, suggestions are highly appreciated guys.
Of any type.

Bjorn - unfortunately it seems this problem is related to E3727 and E3276 
sticks; they can get IP from DHCP but not go ahead.

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
