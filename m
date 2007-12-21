From: Masakazu Mokuno <mokuno-DfbDroY8Xu1L9jVzuh4AOg@public.gmane.org>
Subject: Re: [PATCH] PS3: gelic: Add wireless support for PS3
Date: Fri, 21 Dec 2007 15:17:28 +0900
Message-ID: <20071221150228.BA41.40F06B3A@sm.sony.co.jp>
References: <1197637127.16724.1.camel@localhost.localdomain> <20071215014244.GI5698@jm.kir.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, geoffrey.levand-mEdOJwZ7QcZBDgjK7y7TUQ@public.gmane.org,
	Geert Uytterhoeven <Geert.Uytterhoeven-osDt5Q4Chk1BDgjK7y7TUQ@public.gmane.org>
To: Jouni Malinen <j@w1.fi>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20071215014244.GI5698-mgr6C1c9aYeHXe+LvDLADg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

	Hi Jouni,

On Fri, 14 Dec 2007 17:42:44 -0800
Jouni Malinen <j@w1.fi> wrote:

> However, there is a part that you are not going to like.. This is likely
> using a private ioctl for some parts of the association requests, i.e.,
> no -Dwext.. I would assume that this could be cleaned up, though, if
> WEXT would be extended a bit to allow one more enc_capa to notify
> whether the driver wants to take care of 4-way handshake and to allow
> the PSK to be configured with a new key type.

Yes, as the current WEXT did not have this feature, I could not but
design the new PS3 driver in that way.

> It would be interesting to see whether the driver/firmware/hypervisor
> could be convinced to allow EAPOL frames to go through between
> association and 4-way handshake (which would be completed by
> driver/firmware). This is the way I can support WPA/WPA2-Enterprise with
> OSX..

I had asked the hypervisor guy. Unfortunately all EAPOL frames would be
dropped by the wireless chip firmware.

-- 
Masakazu MOKUNO
