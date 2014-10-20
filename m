From: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Subject: RE: [PATCH net] r8152: use cancel_delayed_work for runtime suspend
Date: Mon, 20 Oct 2014 02:19:27 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB2EC81CA@RTITMBSV03.realtek.com.tw>
References: <1394712342-15778-64-Taiwan-albertk@realtek.com>
 <1413661699.19391.2.camel@linux-0dmf.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	nic_swsd <nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1413661699.19391.2.camel-AfvqVibwNMkMNNZnWhT/Jw@public.gmane.org>
Content-Language: zh-TW
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

 Oliver Neukum [mailto:oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org] 
> Sent: Sunday, October 19, 2014 3:48 AM
[...]
> The diagnosis is good, the fix is not good. It opens a race
> during which the queued work can touch a suspended device.

The delayed work would wake up the device by
calling usb_autopm_get_interface() before
accessing the device. Besides, there is a mutex
to avoid the race.
 
Best Regards,
Hayes
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
