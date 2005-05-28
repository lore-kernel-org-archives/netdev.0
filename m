From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [0/5] Improvements to the ieee80211 layer
Date: Fri, 27 May 2005 23:18:31 -0400
Message-ID: <4297E307.30707@pobox.com>
References: <20050524150711.01632672@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@oss.sgi.com>, LKML <linux-kernel@vger.kernel.org>,
        pavel@suse.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20050524150711.01632672@griffin.suse.cz>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jiri Benc wrote:
> The ieee80211 layer, now present in -mm, lacks many important features
> (actually it's just a part of the ipw2100/ipw2200 driver; these cards do
> a lot of the processing in the hardware/firmware and thus the layer
> currently can not be used for simpler devices).

Agreed.


> This is the first series of patches that try to convert it to a generic
> IEEE 802.11 layer, usable for most of today's wireless cards.

Great!


> The long term plan is:
> - to implement a complete 802.11 stack in the kernel, making it easy to
>   write drivers for simple (cheap) devices
> - to implement all of Ad-Hoc, AP and monitor modes in the layer, so it
>   will be easy to support them in the drivers
> - to integrate Wireless Extensions to unify the kernel-userspace
>   interface of all the drivers
> 
> This means that drivers for "stupid" (simple, cheap) cards should be
> very short and easy to write, whereas drivers for "clever" cards will be
> longer (but still shorter than they are now).
> 
> We have a couple of cards for testing, and we gradually modify the
> drivers for ipw2100 and ipw2200 with the development of the layer. When
> the layer is mature enough for the "stupid" cards, we will rewrite the
> driver for Atheros-based cards to use this layer. We plan to send all
> the patches for these drivers to the netdev list. Of course, we are in
> close contact with Pavel Machek, who is pushing the ipw2100 driver
> upstream.

I'm interesting in writing a RealTek driver using ieee80211.  As the 
ieee80211 layer matures, I'll start publishing that code.

	Jeff
