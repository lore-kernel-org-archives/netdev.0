From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: [PATCH] [TC U32] Fix input parsing to support more than 9 flow
 id'scorrectly
Date: Tue, 12 Feb 2008 19:26:52 -0800
Message-ID: <47B2637C.4070608@vyatta.com>
References: <20080212193725.4137.62287.stgit@localhost.localdomain> <D5C1322C3E673F459512FB59E0DDC3290482CDB1@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:42728 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752170AbYBMD0y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Feb 2008 22:26:54 -0500
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC3290482CDB1@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Waskiewicz Jr, Peter P wrote:
>> From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
>>
>> Using strtoul with a base of 16 converts flowid 10 into 0x10, 
>> which makes it flowid 16.  This is interpreted by the kernel 
>> incorrectly, and causes traffic flows above 9 to be 
>> classified into band 0 on multiband qdiscs.
>> This changes the base to 10, which will correctly parse input 
>> into the proper hexidecimal value.
>>     
>
> Stephen,
> 	We can go one of two ways I suppose.  Once is this way, since
> most user input for CLASSID is base 10, or we can update documentation
> to say that CLASSID input is expected to be base 16.  What do you think?
>
> Thanks,
> -PJ Waskiewicz
> peter.p.waskiewicz.jr@intel.com
>
>   
Sorry, can't change the api, update the documentation instead.
