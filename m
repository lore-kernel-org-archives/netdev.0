From: Tim Gardner <tcanonical-l6nL5VImRDY@public.gmane.org>
Subject: Re: [patch for 2.6.28? 1/1] bluetooth: Dell Wireless 365 requires
 reset quirk
Date: Mon, 01 Dec 2008 17:12:25 -0700
Message-ID: <49347D69.7070807@tpi.com>
References: <200812012201.mB1M155p001654@imap1.linux-foundation.org> <1228169030.31158.154.camel@violet.holtmann.net>
Reply-To: tim.gardner-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	mario_limonciello-8PEkshWhKlo@public.gmane.org, hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, tim.gardner-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org
To: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1228169030.31158.154.camel-Q5NHXjiL5LzjRizqIHwDm9HuzzzSOjJt@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Marcel Holtmann wrote:
> Hi Andrew,
> 
>> This patch causes the BT365 to be reset when the driver is loaded. 
>> Without it, the machine is unable to connect to other devices or to scan
>> for devices.
>>
>> Signed-off-by: Mario Limonciello <mario_limonciello-8PEkshWhKlo@public.gmane.org>
>> Signed-off-by: Tim Gardner <tim.gardner-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
>> Cc: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
>> Cc: Dave Young <hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> Cc: <stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
>> Signed-off-by: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
> 
> NAK. I fixed this differently by making the reset quirk default.
> 
> Regards
> 
> Marcel
> 
> 

Does that mean the devices in blacklist_table that have _only_
BTUSB_RESET should be removed? It would get rid of roughly half of the
entries.

rtg
-- 
Tim Gardner tim.gardner-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org
