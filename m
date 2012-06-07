From: Ben Greear <greearb@candelatech.com>
Subject: Re: tcp wifi upload performance and lots of ACKs
Date: Wed, 06 Jun 2012 17:40:56 -0700
Message-ID: <4FCFF898.8050201@candelatech.com>
References: <4FCCFE76.3060304@candelatech.com> <CAEnQRZCNUYmP88Ocm_nG7gpA1Qcwy1tOc6kgCgZ7RqXcxQsHhg@mail.gmail.com> <4FCFF540.5010608@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Daniel Baluta <dbaluta@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:34900 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756906Ab2FGAk7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2012 20:40:59 -0400
In-Reply-To: <4FCFF540.5010608@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/06/2012 05:26 PM, Ben Greear wrote:
> On 06/04/2012 12:22 PM, Daniel Baluta wrote:
>
>> Currently, there is no way to tune these parameters. Here is an experimental
>> patch [1]. If anyone, thinks that this patch has a chance to get accepted
>> I will be happily try to further improve it.
>>
>>>
>>> Packet traces and other info available if anyone wants to take a look.
>>
>> thanks,
>> Daniel.
>>
>> [1] http://marc.info/?l=linux-netdev&m=131983649130350&w=2
>
> I tried your patch in 3.5.0-rc1.
>
> Doesn't seem to help any...do you have suggested settings for
> the proc values? (I tried increasing tcp_delack_segs up to 10,
> but no significant increase...)
>
> I'll keep poking around.

Ahh, forcing send-buffer to be large helps significantly..wonder
if that was my original problem.

Will get some more useful results tomorrow...

Thanks,
Ben

>
> Thanks,
> Ben
>


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
