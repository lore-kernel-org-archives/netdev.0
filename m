From: Michael Grollman <mgrollman@nscus.com>
Subject: Re: 8169 Intermittent ifup Failure Issue With RTL8102E Chipset in
 Intel's New D945GCLF Atom Board (Not the Initial Modprobe Crash, Another
 Problem)
Date: Wed, 09 Jul 2008 16:31:03 -0700
Message-ID: <48754A37.6040200@nscus.com>
References: <4861800B.90703@nscus.com>	 <20080625213142.GA29890@electric-eye.fr.zoreil.com>	 <48640535.2050000@nscus.com>	 <20080626215918.GC2555@electric-eye.fr.zoreil.com> <1215435236.11909.121.camel@localhost> <487232F4.6000206@dell.com> <4874EFC5.4070008@nscus.com> <4874F60F.2030501@dell.com>
Reply-To: mgrollman@nscus.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kasper Sandberg <lkml@metanurb.dk>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	akpm@linux-foundation.org, linux-pci@vger.kernel.org
To: Mario Limonciello <mario_limonciello@dell.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <4874F60F.2030501@dell.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mario,

I think patch noted below worked to resolve the remaining issues I have 
been experiencing with with realtek Ethernet port on the Intel D945GCLF 
motherboard (Atom Mini-ITX).  I tested with the 2.6.26-rc9 kernel this 
time, although I applied the patch to the 2.6.25's r8169.c.

Likely it is my inexperience, but the patch as I copied it from the 
netdev@vger.kernel.org posting did not apply cleanly using the patch 
tool, so I had to hand-apply the patch code changes to 8169.c.  However, 
once this was done and compiled, the Ethernet began working much 
better.  I have not been able so far to make it fail, even more than two 
dozen or more cold and warm resets.  Previous failure rate was at least 
during 50% of resets, so it is at a minimum much more stable on startup.

Much thanks!

- Michael


Mario Limonciello wrote:
> Hi Michael:
>
> Sorry, I posted this to the list I received your message from
> (netdev@vger.kernel.org).  I don't believe it's been applied by anyone
> as of yet.
>
> Regards
>
> Michael Grollman wrote:
>   
>> Mario,
>>
>> Apologies in advance for my ignorance.
>>
>> When you write below about  'the patch' and 'the list,' can you be a
>> bit more specific, particularly about which list you posted it to?
>>
>> Also, I think Kasper's question below related to, was the patch you
>> used to fix your 8169 issues now part of  rc9, or is it still
>> independent of the main tree?  For those like me not used to be
>> bleeding edge, its cleaner to just snag the rc candidate than to try
>> the hand patch method.
>>
>> Any insight you can offer is appreciated.
>>
>> Cheers,
>>
>> - Michael
>>
>> Mario Limonciello wrote:
>>     
>>> Kasper:
>>>
>>> Particularly try the patch that I posted to the list.  It solved the
>>> ifup (and resume) failures for me on two platforms using that chipset.
>>>
>>> Regards
>>>
>>> Kasper Sandberg wrote:
>>>  
>>>       
>>>> On Thu, 2008-06-26 at 23:59 +0200, Francois Romieu wrote:
>>>>   Sorry for the delay, i had to do an onsite thing in another
>>>> country, so
>>>> i first see your message now.
>>>>
>>>> Would it be okay if i took rc9 instead? also, i saw you posted a set of
>>>> patches to sync more with realteks code, is this something you would
>>>> like me to test too, or aswell? (remember, i have the 8111c).
>>>>
>>>> Btw, a thought just crossed my mind as to a possible reason why this
>>>> might be happening, i was googling around, and it seems the TWO nic's
>>>> are supposed to have some sort of hardware bonding thing, could it be
>>>> because such stuff isnt handled?
>>>>
>>>> mvh.
>>>> Kasper Sandberg
>>>>
>>>> -- 
>>>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>       
>>>>         
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
