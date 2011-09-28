From: Stephen Clark <sclark46@earthlink.net>
Subject: Re: Bridging broken/unfriendly
Date: Wed, 28 Sep 2011 12:10:37 -0400
Message-ID: <4E8346FD.9000306@earthlink.net>
References: <4E7E5976.1070200@earthlink.net> <20110928083021.2edf43a6@nehalam.linuxnetplumber.net>
Reply-To: sclark46@earthlink.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-junco.atl.sa.earthlink.net ([209.86.89.63]:38118 "EHLO
	elasmtp-junco.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750982Ab1I1QKj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2011 12:10:39 -0400
In-Reply-To: <20110928083021.2edf43a6@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/28/2011 11:30 AM, Stephen Hemminger wrote:
> On Sat, 24 Sep 2011 18:28:06 -0400
> Stephen Clark<sclark46@earthlink.net>  wrote:
>
>    
>> Hi,
>>
>> Is there some reason Linux bridging won't let the ip address be on
>> one of the interfaces, like FreeBSD does, instead of the bridge device?
>>
>> This makes it very difficult or impossible to remotely add the interface
>> you are remoted in on to a bridge, or is there some sneaky way to
>> do this without losing your connection?
>>
>>      
> I would like to see a clean solution to setting up a bridge.
> There was a patch that was never completed to allow migrating a ethernet
> interface into a bridge. It is possible to do it with a script, by
> dumping routes with ip command and replaying that into the bridge.
> To really do it right (including neighbor table and iptables rules)
> would be complex, especially considering the error cases.
>
> Having looked at the FreeBSD code, that is not the answer. Trying to keep
> a clean separation between IP and bridging is much better.
>
>    
Hi Stephen,

Thanks for taking the time to reply. I had pretty much decided I would 
have to do some kind
of script that would do everything at once, instead of trying to do the 
commands one at a
time from the console.

Regards,
Steve

-- 

"They that give up essential liberty to obtain temporary safety,
deserve neither liberty nor safety."  (Ben Franklin)

"The course of history shows that as a government grows, liberty
decreases."  (Thomas Jefferson)
