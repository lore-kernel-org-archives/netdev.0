From: Wei Weng <wweng-cRpQ+ttULALQT0dZR+AlfA@public.gmane.org>
Subject: Re: Mark IPW2100 as BROKEN: Fatal interrupt. Scheduling firmware
 restart.
Date: Sun, 21 Sep 2008 14:52:37 -0400
Message-ID: <48D697F5.9050802@acedsl.com>
References: <20080921172316.GA6306@2ka.mipt.ru>	<20080921110422.1d010b96@infradead.org>	<20080921182835.GA11473@2ka.mipt.ru> <20080921113513.16677c4e@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol-9fLWQ3dKdXwox3rIn2DAYQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ipw2100-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Arjan van de Ven <arjan-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080921113513.16677c4e-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Arjan van de Ven wrote:
> On Sun, 21 Sep 2008 22:28:38 +0400
> Evgeniy Polyakov <johnpol-9fLWQ3dKdXwox3rIn2DAYQ@public.gmane.org> wrote:
> 
>> On Sun, Sep 21, 2008 at 11:04:22AM -0700, Arjan van de Ven
>> (arjan-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org) wrote:
>>> so now you go from an occasional burp to having nothing at all.
>>> How about you run with this patch on your own machine only?
>> And how else user can get attention to the problem which is not fixed
>> by the vendor? 
> 
> ... or the community
> 
>> We close our eyes and there is no problem, since we do
>> not see it. I just brought a lamp: no user can see that essentially
>> driver is broken so he can run it on his own risk.
>>
>>> or.. since you say a reload of the driver fixes it.. why don't you
>>> make a patch for the driver that does basically the actions of a
>>> reload automatically when the driver detects the issue?
>>> (and stick a WARN_ON in for good measure so that kerneloops.org can
>>> start tracking these burps)
>> It stops after several seconds (or packets?). Sometimes (but rarely)
>> it works several minutes, sometimes it fires above dmesg line and
>> continues to work, sometimes it fires it for a while and then stops
>> writing it, although driver does not send or receive anything (at
>> least ifconfig counters do not change).
> 
> again.. so how about you detect this condition and do, in the driver
> code, the equivalent of rmmod/insmod to the hardware. I'm sure people
> who have the hardware would appreciate that type of patch a lot more
> than the one you sent out.
> 

I guess it is your way of "middle finger" to all the IPW2100 customers who try
to use it on a Linux machine.


Thanks
Wei


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
