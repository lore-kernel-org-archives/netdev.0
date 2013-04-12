From: Mr Dash Four <mr.dash.four@googlemail.com>
Subject: Re: [PATCH] iproute2: lib/utils.c bug fixes
Date: Fri, 12 Apr 2013 17:16:07 +0100
Message-ID: <51683347.1000806@googlemail.com>
References: <516771D5.3040607@googlemail.com>	<20130411200656.42dfb8bb@nehalam.linuxnetplumber.net>	<516810DD.80008@googlemail.com> <20130412090231.7d8e9c6c@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:43296 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751864Ab3DLQQU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Apr 2013 12:16:20 -0400
Received: by mail-wg0-f44.google.com with SMTP id z11so2808406wgg.23
        for <netdev@vger.kernel.org>; Fri, 12 Apr 2013 09:16:19 -0700 (PDT)
In-Reply-To: <20130412090231.7d8e9c6c@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Stephen Hemminger wrote:
> On Fri, 12 Apr 2013 14:49:17 +0100
> Mr Dash Four <mr.dash.four@googlemail.com> wrote:
>
>   
>> Stephen Hemminger wrote:
>>     
>>> On Fri, 12 Apr 2013 03:30:45 +0100
>>> Mr Dash Four <mr.dash.four@googlemail.com> wrote:
>>>
>>>   
>>>       
>>>> This patch fixes the following 3 bugs in get_u32/get_u64 functions:
>>>>
>>>>   1. On 32-bit systems, get_u32 could not detect an overflow.
>>>>      get_u32(&l, "4294967296", 10) always returned 4294967295
>>>>      (ULONG_MAX on 32-bit systems).
>>>>
>>>>   2. get_u64(&ll, "4294967295", 10) was returning an error where
>>>>      it shouldn't have (4294967295 is perfectly legitimate value for
>>>>      unsigned long long).
>>>>
>>>>   3. get_u64 couldn't detect an overflow errors (arg > ULLONG_MAX)
>>>>
>>>> Signed-off-by: Mr Dash Four <mr.dash.four@googlemail.com>
>>>>     
>>>>         
>>> I don't demand Developer Certificate of Origin on iproute2 patches.
>>> But if you are going to include it then you must use your real name,
>>> no pseudonyms. See kernel/Documentation/SubmittingPatches.
>>>   
>>>       
>> 1. You may or may not be aware that this isn't my first-and-only 
>> contribution to the 
>> Linux/Netfilter/Security/Audit/kernel/any_other_Linux_development_project_you_care_to_mention 
>> tree in which I used my name above.
>> 2. How do you know that Dash Four isn't my name and is a "pseudonym" (do 
>> you consider the name "Dotcom" not to be a real name too, simply because 
>> in your, quite narrow-minded, understanding of the world this name 
>> "looks a bit strange, therefore it must be a pseudonym")?
>> 3. The above text you were kind enough to point me to, is with regards 
>> to kernel submissions. My patch does not alter the kernel tree in any 
>> way whatsoever (but even if it has, see 1. above).
>>     
>
> The issue is that "Signed-off-by" has a legal meaning as defined
> in the kernel SubmittingPatches
>
> <quote>
>
>        Developer's Certificate of Origin 1.1
>
>         By making a contribution to this project, I certify that:
>
>         (a) The contribution was created in whole or in part by me and I
>             have the right to submit it under the open source license
>             indicated in the file; or
>
>         (b) The contribution is based upon previous work that, to the best
>             of my knowledge, is covered under an appropriate open source
>             license and I have the right under that license to submit that
>             work with modifications, whether created in whole or in part
>             by me, under the same open source license (unless I am
>             permitted to submit under a different license), as indicated
>             in the file; or
>
>         (c) The contribution was provided directly to me by some other
>             person who certified (a), (b) or (c) and I have not modified
>             it.
>
> 	(d) I understand and agree that this project and the contribution
> 	    are public and that a record of the contribution (including all
> 	    personal information I submit with it, including my sign-off) is
> 	    maintained indefinitely and may be redistributed consistent with
> 	    this project or the open source license(s) involved.
>
> then you just add a line saying
>
> 	Signed-off-by: Random J Developer <random@developer.example.org>
>
> using your real name (sorry, no pseudonyms or anonymous contributions.)
> </quote>
>
> It was introduced during the SCO pre-trial paranoia phase to deal with
> the possibility of somebody putting something into kernel, then claiming it
> as proprietary.
>
> By putting on Signed-off-by: you are making a legal statement.
> Either resubmit without the Signed-off-by, or give a real name.
>   
I am well-aware of what you just posted, as indicated in my initial 
response you were kind enough to quote above. I would appreciate it if 
you could address the points (1-3) I've made in response to that if you 
disagree, or comment on the content of the actual submission if you 
don't, so we can all move on. Thank you.
