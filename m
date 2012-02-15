From: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH 1/1] usb: cdc-ncm: Increase maximum allowed datagram size
Date: Wed, 15 Feb 2012 09:53:20 +0100
Message-ID: <201202150953.20341.oneukum@suse.de>
References: <1329230375-25508-1-git-send-email-toby.gray@realvnc.com> <20120214.144622.678577766818888054.davem@davemloft.net> <CAL_Kpj0VSu-ByUEwTeVG5-5psab3h38bTL=ot7vYD8A+Oeb_Ug@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, toby.gray-BiNz9QiKYoNBDgjK7y7TUQ@public.gmane.org,
	oliver-Q6YOFhsQ4GZ7tPAFqOLdPg@public.gmane.org, gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAL_Kpj0VSu-ByUEwTeVG5-5psab3h38bTL=ot7vYD8A+Oeb_Ug-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Dienstag, 14. Februar 2012, 23:27:29 schrieb Alexey Orishko:
> On Tue, Feb 14, 2012 at 8:46 PM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
> >
> > Can a USB expert please sanity check this before I apply it?
> 
> I would recommend to change CDC_NCM_NTB_MAX_SIZE_TX(RX) to 32K and
> simply set MAX_DATAGRAM_SIZE to 16K

Have you tried that under severe memory presssure?

	Regards
		Oliver
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
