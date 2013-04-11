From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH 00/11] usbnet: usbnet: handle link change
Date: Thu, 11 Apr 2013 23:27:18 +0800
Message-ID: <CACVXFVMDGOuQ0=hWAWGixrSUwHBRE0D3778F0xJWFtQk-8HS9w@mail.gmail.com>
References: <1365691240-816-1-git-send-email-ming.lei@canonical.com>
	<5166D431.4080400@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jussi Kivilinna <jussi.kivilinna-X3B1VOXEql0@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5166D431.4080400-X3B1VOXEql0@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 11, 2013 at 11:18 PM, Jussi Kivilinna
<jussi.kivilinna-X3B1VOXEql0@public.gmane.org> wrote:
> On 11.04.2013 17:40, Ming Lei wrote:
>> Hi,
>>
>> This patch set introduces usbnet_link_change() API and applies
>> it on all usbnet drivers, then handle the link change centrally
>> to stop bulk transfer when link becomes off and restart bulk
>> transfer when link becomes on.
>
> Should 'rndis_wlan' be changed to use this too?

If link detection of 'rndis_wlan' doesn't depend on
bulk transfer, it can benefit from the change. Otherwise,
it needn't the change, but the patch won't have side-effect
on 'rndis_wlan'.


Thanks,
--
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
