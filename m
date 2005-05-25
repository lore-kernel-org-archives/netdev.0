From: Zhu Yi <yi.zhu@intel.com>
Subject: Re: [0/5] Improvements to the ieee80211 layer
Date: Wed, 25 May 2005 14:55:16 +0800
Message-ID: <1117004116.3737.30.camel@debian.sh.intel.com>
References: <20050524150711.01632672@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@oss.sgi.com>, LKML <linux-kernel@vger.kernel.org>,
        jgarzik@pobox.com, pavel@suse.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20050524150711.01632672@griffin.suse.cz>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2005-05-24 at 15:07 +0200, Jiri Benc wrote:
> The ieee80211 layer, now present in -mm, lacks many important features
> (actually it's just a part of the ipw2100/ipw2200 driver; these cards do
> a lot of the processing in the hardware/firmware and thus the layer
> currently can not be used for simpler devices).
> 
> This is the first series of patches that try to convert it to a generic
> IEEE 802.11 layer, usable for most of today's wireless cards.
> 
> The long term plan is:
> - to implement a complete 802.11 stack in the kernel, making it easy to
>   write drivers for simple (cheap) devices
> - to implement all of Ad-Hoc, AP and monitor modes in the layer, so it
>   will be easy to support them in the drivers
> - to integrate Wireless Extensions to unify the kernel-userspace
>   interface of all the drivers

Do you just clean up current ieee80211 code to still do 802.11 <-> 802.3
conversion inside the driver or you plan to handle real 802.11 frames in
the stack like this?
http://oss.sgi.com/archives/netdev/2005-03/msg01405.html

Thanks,
-yi
