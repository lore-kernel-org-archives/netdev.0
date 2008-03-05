From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: [patch (for 2.6.25?) 2/2] bluetooth: CONWISE Technology based adapters with buggy SCO support (bugzilla #9027)
Date: Wed, 5 Mar 2008 09:46:19 +0100
Message-ID: <CAB9A765-5115-4F9F-A867-44E0CDECF86F@holtmann.org>
References: <200803042258.m24Mw8UK001381@imap1.linux-foundation.org>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	sdiz-A7iEm+J7xfE@public.gmane.org
To: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200803042258.m24Mw8UK001381-AB4EexQrvXRQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

> From: SDiZ <sdiz-A7iEm+J7xfE@public.gmane.org>
>
> Fix the CONWISE Technology based adapters with buggy SCO support issue
> (bugzilla #9027)
>
> Cc: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
> Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> Cc: Dave Young <hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Signed-off-by: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
> ---
>
> drivers/bluetooth/hci_usb.c |    3 +++
> 1 file changed, 3 insertions(+)
>
> diff -puN drivers/bluetooth/hci_usb.c~bluetooth-conwise-technology- 
> based-adapters-with-buggy-sco-support-bugzilla-9027 drivers/ 
> bluetooth/hci_usb.c
> --- a/drivers/bluetooth/hci_usb.c~bluetooth-conwise-technology-based- 
> adapters-with-buggy-sco-support-bugzilla-9027
> +++ a/drivers/bluetooth/hci_usb.c
> @@ -148,6 +148,9 @@ static struct usb_device_id blacklist_id
> 	{ USB_DEVICE(0x0400, 0x0807), .driver_info = HCI_BROKEN_ISOC },
> 	{ USB_DEVICE(0x0400, 0x080a), .driver_info = HCI_BROKEN_ISOC },
>
> +	/* CONWISE Technology based adapters with buggy SCO support */
> +	{ USB_DEVICE(0x0e5e, 0x6622), .driver_info = HCI_BROKEN_ISOC },

this is the one with the proper description and acked by me. Please  
drop the other one.

Regards

Marcel

--
To unsubscribe from this list: send the line "unsubscribe linux-bluetooth" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
