From: <Mario_Limonciello-DYMqY+WieiM@public.gmane.org>
Subject: RE: [PATCH] r8152: Add support for setting MAC to system's Auxiliary
 MAC address
Date: Fri, 3 Jun 2016 14:52:20 +0000
Message-ID: <239bcff4e3334cb6bc6fabc65973e3e7@ausx13mpc124.AMER.DELL.COM>
References: <1464817844-27206-1-git-send-email-mario_limonciello@dell.com>
 <20160601230535.GA29279@kroah.com>
 <0bdb98b72b884682b936c0587f965629@ausx13mpc124.AMER.DELL.COM>
 <20160602152244.GA26494@kroah.com>
 <6d9575fd791c4e25b464b9a1b11daa83@ausx13mpc124.AMER.DELL.COM>
 <20160602160902.GA27948@kroah.com>
 <5a22a497af9e467582221cd3a10c90ff@ausx13mpc124.AMER.DELL.COM>
 <0835B3720019904CB8F7AA43166CEEB2FED973@RTITMBSV03.realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	<anthony.wong-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
To: <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>, <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <0835B3720019904CB8F7AA43166CEEB2FED973-JIZ+AM9kKNzuvTFwvkocLypo8c9IxeqyAjHCUHv49ws@public.gmane.org>
Content-Language: en-US
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Hayes Wang [mailto:hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org]
> Sent: Friday, June 3, 2016 4:23 AM
> To: Limonciello, Mario <Mario_Limonciello-DYMqY+WieiM@public.gmane.org>;
> gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org
> Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-
> usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org; anthony.wong-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org
> Subject: RE: [PATCH] r8152: Add support for setting MAC to system's
> Auxiliary MAC address
> 
> Mario_Limonciello-DYMqY+WieiM@public.gmane.org [mailto:Mario_Limonciello-DYMqY+WieiM@public.gmane.org]
> > Sent: Friday, June 03, 2016 12:58 AM
> [...]
> > > Why generate a random one and not just use the one that the network
> > > controler already provides?
> >
> > That's how the flow works in r8152 already and I'm not overriding it.
> > Again, I'll send V2 and you'll see what I did.
> 
> The original flows are
> 1. Read MAC address 1 from device.
> 2. Check if the MAC address 1 is valid.
> 3. Use random MAC address if MAC address 1 is invalid.
> 
> However, your flow would be
> 1. Read MAC address 1 from device.
> 2. Read MAC address 2 from ACPI.
> 3. Check if the MAC address 2 is valid.
> 4. Use random MAC address if MAC address 2 is invalid.
> 
> Although MAC address 2 may be invalid, MAC address 1 may be valid.
> For this situation, you have to use MAC address 1, not random one.
> 
> Best Regards,
> Hayes

Hi Hayes,

Once I get information about how to read docking bit, I'll adjust that for v3
to ensure that it falls back to MAC address 1 if #2 is invalid.

Thanks
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
