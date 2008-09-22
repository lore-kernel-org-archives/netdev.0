From: Michael Grollman <mgrollman@nscus.com>
Subject: Re: 8169 Intermittent ifup Failure Issue With RTL8102E Chipset in
 Intel's New D945GCLF Atom Board (Not the Initial Modprobe Crash, Another
 Problem)
Date: Mon, 22 Sep 2008 10:20:10 -0700
Message-ID: <48D7D3CA.8040706@nscus.com>
References: <4861800B.90703@nscus.com>	 <20080625213142.GA29890@electric-eye.fr.zoreil.com>	 <48640535.2050000@nscus.com>	 <20080626215918.GC2555@electric-eye.fr.zoreil.com>	 <1215435236.11909.121.camel@localhost>  <487232F4.6000206@dell.com>	 <1215783324.11909.185.camel@localhost>  <48777BC3.6090108@dell.com> <1216052460.23392.14.camel@localhost>
Reply-To: mgrollman@nscus.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mario Limonciello <mario_limonciello@dell.com>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	akpm@linux-foundation.org, linux-pci@vger.kernel.org
To: Kasper Sandberg <lkml@metanurb.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp111.sat.emailsrvr.com ([66.216.121.111]:58705 "EHLO
	smtp111.sat.emailsrvr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751095AbYIVRUQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 13:20:16 -0400
In-Reply-To: <1216052460.23392.14.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Did Francois's patch ever make it upstream?  I recently tested against a 
stock debian sid kernel based on 2.6.26-5, and although my tests were 
not exhaustive, it seemed that the 8169 failure mode was still present. 


Kasper Sandberg wrote:
> On Fri, 2008-07-11 at 10:26 -0500, Mario Limonciello wrote:
>   
>> Kasper:
>>
>> http://marc.info/?l=linux-netdev&m=121498012600793&w=2
>>     
>
> I just tested it. It fails.
>
> after a few unloads/loads the lspci -x output is garbled again. the
> funny thing is (i have a dual nic board) its random which one that
> breaks..
>
> Francois, i tested your patch,
> http://userweb.kernel.org/~romieu/r8169/2.6.26-rc9/20080710-r8169-test.patch against .26 and it WORKS. with all the other tests i've done, ~5 unloads/loads is more than enough to trigger it, i just did 50 on your patch, and it functions.
>
> Now i can have both msi and apic on.. Thanks alot.
>
> Do you have plans to get this merged?
>
>   
>> Regards
>>
>> Kasper Sandberg wrote:
>>     
>>> On Mon, 2008-07-07 at 10:15 -0500, Mario Limonciello wrote:
>>>   
>>> Sorry, i am not subscribed to netdev or pci list, could you post here
>>> aswell?
>>>
>>>   
>>>
>>>   
>>>       
>
>   

-- 
Michael Grollman
National Scientific Corporation
8361 East Evans Rd Ste 106
Scottsdale, AZ.  85260  USA
Voice: +1-480-948-8324 x 303
Fax: +1-480-483-8893
mgrollman@nscus.com
www.nsct.info

