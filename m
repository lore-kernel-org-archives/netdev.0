From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: /proc/net/igmp group address encoding
Date: Wed, 24 Sep 2008 23:12:17 +0300 (EEST)
Message-ID: <alpine.LRH.2.00.0809242310100.9495@netcore.fi>
References: <OFF76F11EC.DE83396F-ON882574CE.00619859-882574CE.00622571@us.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netcore.fi ([193.94.160.1]:39056 "EHLO netcore.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751652AbYIXUcG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2008 16:32:06 -0400
In-Reply-To: <OFF76F11EC.DE83396F-ON882574CE.00619859-882574CE.00622571@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 24 Sep 2008, David Stevens wrote:
> netdev-owner@vger.kernel.org wrote on 09/24/2008 04:20:48 AM:
>> On Wed, 24 Sep 2008, Pekka Savola wrote:
>>> [psavola@lapps ~]$ more /proc/net/igmp
>>> Idx   Device    : Count Querier   Group    Users Timer   Reporter
>>> 1   lo        :     0      V3
>>>             010000E0     1 0:00000000      0
>>> 2   eth0      :     2      V3
>>>             010000E0     1 0:00000000      0
>>> 3   wmaster0  :     3      V3
>>>             010000E0     1 0:00000000      0
>>> 4   wlan0     :     3      V3
>>>              010000E0     1 0:00000000      0
>>>
>>> (The header and the fields seem to be a little off in the output..)
>>>
>>> [psavola@lapps ~]$ netstat -gn | grep eth0
>>> eth0            1      224.0.0.1
>>> eth0            1      ff02::1
>>
>> Another observation here:  the "Count" field appears to correspond to
>> 'netstat -gn | wc -l' output.  But this includes both IPv4 and IPv6
>> groups.  Is this intentional?  Shouldn't this only count the v4
>> entries, just like /proc/net/igmp6 only includes v6 entries?
>
> I'm guessing this is Alan Cox's code, but it's at least 8 years
> old, so I'm not sure original intent is easy to establish. :-)
>
> I agree it'd be a good idea to separate the counts. Are you
> planning to do a patch?

I'm less than familiar with the code in question and not best placed 
to work on this, so if you (or someone else) would be 
interested/willing to do this, great.  If nothing happens, I may need 
to reconsider my options..

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
