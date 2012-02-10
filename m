From: Ben Greear <greearb@candelatech.com>
Subject: Re: r8169 crash (probably my fault) in 3.3.0-rc1+ (net-next)
Date: Fri, 10 Feb 2012 11:29:19 -0800
Message-ID: <4F35700F.5010708@candelatech.com>
References: <4F3446AB.2080209@candelatech.com> <20120210093006.GA23710@electric-eye.fr.zoreil.com> <4F354F51.7070202@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:47277 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752637Ab2BJT3X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2012 14:29:23 -0500
In-Reply-To: <4F354F51.7070202@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/10/2012 09:09 AM, Ben Greear wrote:
> On 02/10/2012 01:30 AM, Francois Romieu wrote:
>> Ben Greear<greearb@candelatech.com> :
>> [...]
>>> I am hacking on the 8169 code, (adding RX-ALL and RX-FCS support on top
>>> of my previously posted patches) so this could easily be my fault..
>>> but just in case someone else has seen it, please let me know....
>>
>> I have never met it before. Neither does the web.
>>
>> Are you hacking against davem's -next branch ?
>
> Yes. I was testing the attached patch, and when I enabled the rx-fcs, it crashed
> shortly after. So, my changes must be bad somehow...
>
> Probably something to do with pkt_size being 4 bytes larger when
> rx-fcs is enabled (I was hoping that would grab the FCS, as similar
> logic seems to work fine in 8139too...)

I cannot reproduce the problem, so maybe I had a funky build
or just got unlucky with some extraneous bug.

With that patch applied, rtl8169 seems to support rx-all
and rx-fcs just fine (tested with frames with bad FCS).

If/when the framework patches get accepted I'll post
the 8139too and rtl8169 patches for formal review.

Thanks,
Ben

>
> Thanks,
> Ben
>


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
