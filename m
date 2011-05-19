From: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH v2] CDC NCM: release interfaces fix in unbind()
Date: Thu, 19 May 2011 15:40:58 +0200
Message-ID: <201105191540.58291.oneukum@suse.de>
References: <1305662344-28355-1-git-send-email-alexey.orishko@stericsson.com> <Pine.LNX.4.44L0.1105181053110.2131-100000@iolanthe.rowland.org> <2AC7D4AD8BA1C640B4C60C61C8E520153E3ACE0774@EXDCVYMBSTM006.EQ1STM.local>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	"gregkh-l3A5Bk7waGM@public.gmane.org" <gregkh-l3A5Bk7waGM@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Alexey ORISHKO <alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <2AC7D4AD8BA1C640B4C60C61C8E520153E3ACE0774-8ZTw5gFVCTjVH5byLeRTJxkTb7+GphCuwzqs5ZKRSiY@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Mittwoch, 18. Mai 2011, 19:11:37 schrieb Alexey ORISHKO:
> I wonder, if Greg or Oliver could provide any comments why master interface
> is not claimed in modem/ether drivers, since they are working with the
> code for quite a while.

Probe is called for the master interface. You claim only _additional_
interfaces. The problem is in disconnect(). You may be called in any order.

	HTH
		Oliver

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
