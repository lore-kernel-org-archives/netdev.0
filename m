From: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Is this 32-bit NCM?
Date: Fri, 28 Nov 2014 06:59:29 +0100 (CET)
Message-ID: <alpine.LNX.2.03.1411280655390.1286@gmail.com>
References: <alpine.LNX.2.03.1411262250160.4356@gmail.com> <87ppc957h1.fsf@nemi.mork.no> <alpine.LNX.2.03.1411271037050.9464@gmail.com> <874mtl55ar.fsf@nemi.mork.no> <CAPChA0cLuvRpYTYuFoi3bewqASgf_oZHSz5yQQ8JYm96dZ4-TQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: =?ISO-8859-15?Q?Bj=F8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>,
	ShaojunMidge.Tan-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org, Mingying.Zhu-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org,
	youtux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Eli.Britstein-6C2+4RG2qWF0ubjbjo6WXg@public.gmane.org
To: Alex Strizhevsky <alexxst-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAPChA0cLuvRpYTYuFoi3bewqASgf_oZHSz5yQQ8JYm96dZ4-TQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello to everyone.
Can you guys try to compare what happens withe standard, and 32-bit version of 
the driver, with the E3276, so that we see what happens and what are the 
differences?
And it would be very nice if you look what happens with the standard 16-bit 
driver to confirm what Bjorn suspected regarding the alignment problems: this 
morning I will take a lookt at the align_tail function (it's called something 
like that) in cdc_ncm.c (standard version).

Bjorn and all: do you think it's ok if I keep you all + mailing lists in CC or 
would you like me to do something different? Please comment on this if any 
change is required.
Taking a shower right now,
Enrico
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
