From: Kalle Valo <kvalo-BkwN83ws05HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC/RFT 14/15] rtlwifi: Modify files for addition of rtl8723ae
Date: Fri, 14 Sep 2012 09:10:56 +0300
Message-ID: <87mx0t3zin.fsf@purkki.adurom.net>
References: <1347483294-6943-1-git-send-email-Larry.Finger@lwfinger.net>
	<1347483294-6943-15-git-send-email-Larry.Finger@lwfinger.net>
	<CAGRGNgWezEzXV0-k6DA7TckNpa=zgN6LNv898N-PRU6P1LYgOw@mail.gmail.com>
	<505170C6.8090003@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Julian Calaby <julian.calaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <505170C6.8090003-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org> (Larry Finger's message of "Thu,
	13 Sep 2012 00:36:06 -0500")
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org> writes:

>> Is this supposed to be bit #29 - I notice that COMP_USB is also bit 29.
>
> Yes, that is OK. One will only be used for PCI-based drivers, and the
> other is obviously for USB. As nearly all the bits of a 32-bit
> quantity are used, I wanted to save one if possible.
>
> In the final version, I'll code this as
>
> #define COMP_USB                       BIT(29)
> #define COMP_EASY_CONCURRENT           COMP_USB
>
> That way will be more obvious.

You could also add a comment explaining it, just to make sure that
everyone understands it.

-- 
Kalle Valo
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
