From: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH] CDC NCM: release interfaces fix in unbind()
Date: Tue, 17 May 2011 08:26:42 +0200
Message-ID: <201105170826.42212.oneukum@suse.de>
References: <1305491307-6548-1-git-send-email-alexey.orishko@stericsson.com> <20110516.151302.89070822321885499.davem@davemloft.net> <2AC7D4AD8BA1C640B4C60C61C8E520153E3A93E8EE@EXDCVYMBSTM006.EQ1STM.local>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"gregkh-l3A5Bk7waGM@public.gmane.org" <gregkh-l3A5Bk7waGM@public.gmane.org>
To: Alexey ORISHKO <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <2AC7D4AD8BA1C640B4C60C61C8E520153E3A93E8EE-8ZTw5gFVCTjVH5byLeRTJxkTb7+GphCuwzqs5ZKRSiY@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Dienstag, 17. Mai 2011, 02:52:34 schrieb Alexey ORISHKO:

> Some confusion was added by other driver code that handles crippled
> devices, which mix ctrl and data interfaces... Shall not be the case here.
> I see, that some clean up can be done and "xxx_claimed" fields in context
> structure can be removed, so will post a new version of patch shortly.

This code is a bit tricky in those drivers because you cannot assume a certain
order of calls to disconnect() w.r.t. the interfaces. If you claim multiple
interfaces, you need to release all other interfaces, as soon as any interface
is disconnected.

	Regards
		Oliver
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
