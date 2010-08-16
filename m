From: Ben Greear <greearb@candelatech.com>
Subject: Re: [iproute2] iproute2:  Fix 'addr flush secondary' logic.
Date: Mon, 16 Aug 2010 10:01:01 -0700
Message-ID: <4C696ECD.8080000@candelatech.com>
References: <1281547182-1252-1-git-send-email-greearb@candelatech.com> <4C630B0A.9010304@hp.com> <4C6328A8.4070703@candelatech.com> <4C6444EA.1070704@hp.com> <4C65A1CD.5090800@candelatech.com> <4C696014.4080508@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:55892 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752359Ab0HPRBF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Aug 2010 13:01:05 -0400
In-Reply-To: <4C696014.4080508@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/16/2010 08:58 AM, Brian Haley wrote:
> On 08/13/2010 03:49 PM, Ben Greear wrote:
>> Attached is an updated patch to fix some of the errors you
>> mentioned.  It also fixes a bug when '-s -s' is used:  The old
>> code modified the ifa flags, which made it not handle the check
>> for primary v/s secondary correctly in the next filter.
>
> Thanks for the update, nitpicking comments below.
>
> BTW, promote_secondaries was the reason for some of my testing
> issues as I don't usually run with that enabled.

Thanks for all the help and suggestions.  I just sent an
'official' patch with your final suggestions included.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

