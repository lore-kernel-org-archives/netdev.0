From: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 3/5] usb: usbnet: Allow drivers using usbnet to specify maximum packet size
Date: Wed, 15 Feb 2012 20:35:11 +0100
Message-ID: <201202152035.11779.oliver@neukum.org>
References: <1329317261-3406-1-git-send-email-toby.gray@realvnc.com> <1329317261-3406-4-git-send-email-toby.gray@realvnc.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Toby Gray <tg-BiNz9QiKYoNBDgjK7y7TUQ@public.gmane.org>, Oliver Neukum <oliver-Q6YOFhsQ4GZ7tPAFqOLdPg@public.gmane.org>,
	"Greg Kroah-Hartman" <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: Toby Gray <toby.gray-BiNz9QiKYoNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1329317261-3406-4-git-send-email-toby.gray-BiNz9QiKYoNBDgjK7y7TUQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Mittwoch, 15. Februar 2012, 15:47:39 schrieb Toby Gray:
> The usbnet driver always attempts to set dev->maxpacket from the out
> endpoint. For this to function correctly it relies on the alternate
> setting containg the bulk out endpoint to be selected. This isn't
> necessarily always the case.
> 
> This change allows drivers that make use of usbnet to specify the
> value for dev->maxpacket themselves.
> 
> Signed-off-by: Toby Gray <toby.gray-BiNz9QiKYoNBDgjK7y7TUQ@public.gmane.org>
Acked-by: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>

	Regards
		Oliver
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
