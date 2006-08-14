From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: wlan#ap seems bogus
Date: Mon, 14 Aug 2006 18:04:24 +0200
Message-ID: <44E09F08.8090104@sipsolutions.net>
References: <44E02F41.2060300@sipsolutions.net> <44E032CA.4040107@sipsolutions.net> <20060814155847.GC1196@instant802.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:40933 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1750852AbWHNQFJ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Aug 2006 12:05:09 -0400
To: Jouni Malinen <jkm@devicescape.com>
In-Reply-To: <20060814155847.GC1196@instant802.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jouni Malinen wrote:
>> How about we just add a new interface mode called MGT_MONITOR and
>> wpa_supplicant simply creates a new device via the regular sysfs mechanism,
>> and then sets that MGT_MONITOR mode via the relevant WEXT ioctl? iwconfig
>> doesn't even need to be taught about this mode except for display
>> purposes...
>>     
>
> Isn't this already done? I don't remember what happened with client mode
> case, but at least hostapd is requesting the management interface
> dynamically at startup time.
>
>   
Yes, it's requesting it, but via a private wext call. I'd like to see it 
generic, and allow multiple mgmt interfaces as well if the user/hw so 
wishes. IOW I'd like to remove the iwpriv call and instead use the 
equivalent of "echo -n wmgmt0 > /sys/class/ieee80211/phy0/add_iface ; 
iwconfig wmgmt0 mode management"

> Same here.. hostapd gets the ifindex from kernel and doesn't care about
> the name.
>   
Good point, I overlooked that.

johannes

