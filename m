From: Alexey ORISHKO <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
Subject: RE: [PATCH] USB CDC NCM: tx_fixup() race condition fix
Date: Mon, 17 Jan 2011 16:04:32 +0100
Message-ID: <2AC7D4AD8BA1C640B4C60C61C8E520153BB5B84E45@EXDCVYMBSTM006.EQ1STM.local>
References: <1295271573-8890-1-git-send-email-alexey.orishko@stericsson.com>
 <4D3458F7.5070209@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"gregkh-l3A5Bk7waGM@public.gmane.org" <gregkh-l3A5Bk7waGM@public.gmane.org>,
	"yauheni.kaliuta-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org" <yauheni.kaliuta-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
To: Sergei Shtylyov <sshtylyov-Igf4POYTYCDQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4D3458F7.5070209-hkdhdckH98+B+jHODAdFcQ@public.gmane.org>
Content-Language: en-US
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> > - tx_fixup() call be called from either timer callback or from xmit()
> 
>     s/call/can/?
Yes :-)

> 
> >   in usbnet, so spinlock is added to avoid concurrency-related
> problem.
> > - minor correction due checkpatch warning for some line over 80 chars
> 
>     Due to?
yep

Sorry for typos...

Regards,
alexey
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
