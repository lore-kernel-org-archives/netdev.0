From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 4/7] usbnet: remove EVENT_DEV_OPEN flag
Date: Tue, 12 Jun 2012 20:14:28 +0200
Message-ID: <201206122014.28408.oliver@neukum.org>
References: <1339463985-9006-1-git-send-email-tom.leiming@gmail.com> <1339463985-9006-5-git-send-email-tom.leiming@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Greg Kroah-Hartman" <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1339463985-9006-5-git-send-email-tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Dienstag, 12. Juni 2012, 03:19:42 schrieb Ming Lei:
> EVENT_DEV_OPEN is introduced to mark if the interface is opened or
> not, but we already have IFF_UP to handle it, so just
> remove the flag and use IFF_UP.

When is IFF_UP cleared? The flag is tested in usbnet_resume(),
so it must be cleared before usbnet_stop() is called.

	Regards
		Oliver
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
