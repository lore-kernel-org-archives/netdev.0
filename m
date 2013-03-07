From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH] macvlan: Set IFF_UNICAST_FLT flag to prevent unnecessary
 promisc mode.
Date: Thu, 07 Mar 2013 15:32:26 -0500
Message-ID: <5138F95A.9010305@redhat.com>
References: <1362687708-8685-1-git-send-email-vyasevic@redhat.com> <5138F82F.6010005@candelatech.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34969 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752783Ab3CGUc2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Mar 2013 15:32:28 -0500
In-Reply-To: <5138F82F.6010005@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/07/2013 03:27 PM, Ben Greear wrote:
> On 03/07/2013 12:21 PM, Vlad Yasevich wrote:
>> Macvlan already supports hw address filters.  Set the IFF_UNICAST_FLT
>> so that it doesn't needlesly enter PROMISC mode when macvlans are
>> stacked.
>
> Out of curiosity, how can stacking mac-vlans be useful?
>
> (You are stacking more macvlans on a base mac-vlan?)

Yep, and macvlans allows, but it looks like it only tries to detect a 2 
level stack.  I am not sure what the reason is.  Might be realated to 
vlan-to-vlan communication.

-vlad

>
> Thanks,
> Ben
>
