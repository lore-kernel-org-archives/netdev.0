From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v1 0/5] usbnet: avoiding access auto-suspended device
Date: Mon, 05 Nov 2012 11:50:10 -0500 (EST)
Message-ID: <20121105.115010.1531838246984342873.davem@davemloft.net>
References: <1351992594-12818-1-git-send-email-ming.lei@canonical.com>
	<9016904.gHGBncEQ14@linux-lqwf.site>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org, gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: oneukum-l3A5Bk7waGM@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <9016904.gHGBncEQ14-ugxBuEnWX9yG/4A2pS7c2Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Date: Mon, 05 Nov 2012 10:24:57 +0100

> On Sunday 04 November 2012 09:29:49 Ming Lei wrote:
>> Thip patchset avoids accessing auto-suspended device in ioctl path,
>> which is generally triggered by some network utility(ethtool, ifconfig,
>> ...)
>> 
>> Most of network devices have the problem, but as discussed in the
>> thread:
>> 
>>         http://marc.info/?t=135054860600003&r=1&w=2
>> 
>> the problem should be solved inside driver.
>> 
>> Considered that only smsc75xx and smsc95xx calls usbnet_read_cmd()
>> and usbnet_write_cmd() inside its resume and suspend callback, the
>> patcheset introduce the nopm version of the two functions which
>> should be called only in the resume and suspend callback. So we
>> can solve the problem by runtime resuming device before doing
>> control message things.
> 
> Hi,
> 
> I am happy with these patches.
> Dave, do you have a principal objection regarding these patches, too?

There were review comments and the most recently posted series
needs to be reposted with that feedback incorporated.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
