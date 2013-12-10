From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: ifconfig doesn't show assignment ip-addresses
Date: Tue, 10 Dec 2013 13:57:54 +0100
Message-ID: <20131210125754.GC2469@minipsycho.orion>
References: <20131209153238.GA10317@omega>
 <20131210105741.GA2469@minipsycho.orion>
 <20131210110648.GA18196@omega>
 <20131210114339.GB2469@minipsycho.orion>
 <20131210114847.GA20146@omega>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Alexander Aring <alex.aring@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f50.google.com ([74.125.83.50]:40310 "EHLO
	mail-ee0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751498Ab3LJM56 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 07:57:58 -0500
Received: by mail-ee0-f50.google.com with SMTP id c41so2185766eek.23
        for <netdev@vger.kernel.org>; Tue, 10 Dec 2013 04:57:57 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20131210114847.GA20146@omega>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Dec 10, 2013 at 12:48:48PM CET, alex.aring@gmail.com wrote:
>On Tue, Dec 10, 2013 at 12:43:39PM +0100, Jiri Pirko wrote:
>> Tue, Dec 10, 2013 at 12:06:49PM CET, alex.aring@gmail.com wrote:
>> >Hi,
>> >
>> >thanks for your reply.
>> >
>> >On Tue, Dec 10, 2013 at 11:57:41AM +0100, Jiri Pirko wrote:
>> >> Mon, Dec 09, 2013 at 04:32:39PM CET, alex.aring@gmail.com wrote:
>> >> >Hi,
>> >> >
>> >> >On current net-next with a lowpan interface created with:
>> >> >
>> >> >ip link add link wpan0 name lowpan0 type lowpan
>> >> >
>> >> >I don't see any ipv6 addresses in ifconfig anymore. The addresses exist,
>> >> >because I can ping my device.
>> >> 
>> >> 
>> >> Can you see the address in "ip a" ? Would you send me output of
>> >> "ifconfig" and "ip a" please? Is this a problem for lowpan only or do
>> >> you see this with other device types as well?
>> >> 
>> 
>> The problem is that ifconfig parses /proc/net/if_inet6 which changed
>> flag format from 2 hexa chars to 3.
>> I will send revert for this change in couple of minutes.
>> 
>
>ah, nice to known. Thanks!
>
>What would be a proper solution to add a u32 flag property? Or we never
>should change this, because we want backwards compatibility?

I think that we should leave this as it is. The u32 flags are reachable
via Netlink and that is the preferred way nowadays.

>
>- Alex
