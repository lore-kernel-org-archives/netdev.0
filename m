From: "Michael Kerrisk" <mtk.manpages-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Subject: Documentation RFC: MSG_TRUNC and TCP sockets
Date: Mon, 1 Dec 2008 11:16:01 -0500
Message-ID: <cfd18e0f0812010816m5c8a689t2c28421d1bcdac84@mail.gmail.com>
Reply-To: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Hamish Moffatt" <hamish-8fiUuRrzOP0dnm+yROfE0A@public.gmane.org>, linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"David Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Stephen Hemminger" <shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	"Andi Kleen" <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

After a bug report from Hamish, I did some reading to determine
meaning of MSG_TRUNC for TCP sockets.  I'd appreciate confirmation
that the following text, scheduled the tcp(7) page in man-pages-3.15,
matches reality, and the developers' intentions (but I am not sure who
implemented this piece).

       Since version 2.4, Linux supports the use of MSG_TRUNC in
       the flags argument of  recv(2)  (and  recvmsg(2)).   This
       flag  causes  the received bytes of data to be discarded,
       rather than passed  back  in  a  caller-supplied  buffer.
       Since  Linux  2.4.4,  MSG_PEEK  also has this effect when
       used in conjunction with MSG_OOB to  receive  out-of-band
       data.

Cheers,

Michael
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
