From: Ben Greear <greearb@candelatech.com>
Subject: Re: TCP connection hang problem with 2.6.16.16, e1000.
Date: Wed, 31 May 2006 11:00:21 -0700
Message-ID: <447DD9B5.9050100@candelatech.com>
References: <447DC830.4080201@candelatech.com> <447DD870.80107@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:45546 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S1751766AbWEaSAY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 May 2006 14:00:24 -0400
To: Auke Kok <auke-jan.h.kok@intel.com>
In-Reply-To: <447DD870.80107@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> Ben Greear wrote:
> 
>> Kernel is 2.6.16.16 with my patches, including a patch to the
>> e1000.
> 
> 
> what patch? I don't see it anywhere.

Well, it's reproducible with only the send-to-self patch, so I figured it wouldn't
help to show the e1000 patches.  Also, it is reproducible on tg3, so it is not
e1000 specific, though it is slightly easier to trigger on e1000
for some reason (possibly higher throughput or something specific
about my configuration.)

I haven't seen this problem on 2.6.13, so I'm now starting a manual bisect
to see if I can narrow down where the problem appeared.

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

