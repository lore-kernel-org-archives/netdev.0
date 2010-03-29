From: Stephen Clark <sclark46-ihVZJaRskl1bRRN4PJnoQQ@public.gmane.org>
Subject: Re: [ANNOUNCEMENT] NET: usb: sierra_net.c driver
Date: Mon, 29 Mar 2010 08:30:45 -0400
Message-ID: <4BB09D75.7020500@earthlink.net>
References: <1269652919.30630.1.camel@Linuxdev3>	 <1269791821.11714.202.camel@localhost.localdomain>	 <4BAFAA2C.8060604@earthlink.net> <1269823442.8653.261.camel@localhost>
Reply-To: sclark46-ihVZJaRskl1bRRN4PJnoQQ@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	Elina Pasheva <epasheva-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>,
	David Brownell <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	Rory Filer <rfiler-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1269823442.8653.261.camel@localhost>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 03/28/2010 08:44 PM, Ben Hutchings wrote:
> On Sun, 2010-03-28 at 15:12 -0400, Stephen Clark wrote:
>> On 03/28/2010 11:57 AM, Marcel Holtmann wrote:
>>> Hi Elina,
>>>
>>>> +static const struct driver_info sierra_net_info_68A3 = {
>>>> +	.description = "Sierra Wireless USB-Ethernet Modem",
>>>> +	.flags = FLAG_ETHER | FLAG_SEND_ZLP,
>>>> +	.bind = sierra_net_bind,
>>>> +	.unbind = sierra_net_unbind,
>>>> +	.status = sierra_net_status,
>>>> +	.rx_fixup = sierra_net_rx_fixup,
>>>> +	.tx_fixup = sierra_net_tx_fixup,
>>>> +	.data = (unsigned long)&sierra_net_info_data_68A3,
>>>> +};
>>>
>>> the FLAG_ETHER is wrong here. Please use FLAG_WWAN to clearly mark these
>>> interfaces.
>>>
>>> Otherwise we have wrong DEVTYPE uevent assignments and userspace will
>>> treat them as real Ethernet cards. And that should not happen. As a nice
>> Why shouldn't that happen if they look like NIC cards?
> [...]
>
> This information is important for management interfaces.  The user
> doesn't care what your device looks like at the kernel level - they know
> it's a wireless broadband device and they expect to see a device
> labelled as such in Network Manager or whatever they use.
>
> Ben.
>
You sound like a windows guy! Whats with everything having to use 
NetworkManager!? Are people so dumb they can't figure things out from
the command line. If it acts like a NIC it should be a NIC. I am
so tired of eveyone trying to make Linux look and act like WINBLOWS.

-- 

"They that give up essential liberty to obtain temporary safety,
deserve neither liberty nor safety."  (Ben Franklin)

"The course of history shows that as a government grows, liberty
decreases."  (Thomas Jefferson)


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
