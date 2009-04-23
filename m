From: Ben Greear <greearb@candelatech.com>
Subject: Re: ath5k irq warning message
Date: Thu, 23 Apr 2009 09:27:12 -0700
Message-ID: <49F096E0.8030302@candelatech.com>
References: <49EF9276.1060109@candelatech.com> <20090423120638.GA3168@hash.localnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Bob Copeland <me@bobcopeland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:37646 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754637AbZDWQ1k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2009 12:27:40 -0400
In-Reply-To: <20090423120638.GA3168@hash.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bob Copeland wrote:
> On Wed, Apr 22, 2009 at 02:56:06PM -0700, Ben Greear wrote:
>> I notice this code in the ath5k_intr method.
>>
>> Won't counter be -1 if you break out of this due to the 'counter-- > 0'
>> clause?
>>
>> 	} while (ath5k_hw_is_intr_pending(ah) && counter-- > 0);
> 
> Good catch, I guess it should be --counter...

That works for me.

Seems the root cause of my problem might have been fixed already
by the patch to turn off BMISS irqs, btw...about to start
testing that now.

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

