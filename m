From: Mr Dash Four <mr.dash.four@googlemail.com>
Subject: Re: [PATCH] iproute2: lib/utils.c bug fixes
Date: Fri, 12 Apr 2013 14:49:17 +0100
Message-ID: <516810DD.80008@googlemail.com>
References: <516771D5.3040607@googlemail.com> <20130411200656.42dfb8bb@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f173.google.com ([74.125.82.173]:35899 "EHLO
	mail-we0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755074Ab3DLNta (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Apr 2013 09:49:30 -0400
Received: by mail-we0-f173.google.com with SMTP id t57so2015617wey.4
        for <netdev@vger.kernel.org>; Fri, 12 Apr 2013 06:49:28 -0700 (PDT)
In-Reply-To: <20130411200656.42dfb8bb@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Stephen Hemminger wrote:
> On Fri, 12 Apr 2013 03:30:45 +0100
> Mr Dash Four <mr.dash.four@googlemail.com> wrote:
>
>   
>> This patch fixes the following 3 bugs in get_u32/get_u64 functions:
>>
>>   1. On 32-bit systems, get_u32 could not detect an overflow.
>>      get_u32(&l, "4294967296", 10) always returned 4294967295
>>      (ULONG_MAX on 32-bit systems).
>>
>>   2. get_u64(&ll, "4294967295", 10) was returning an error where
>>      it shouldn't have (4294967295 is perfectly legitimate value for
>>      unsigned long long).
>>
>>   3. get_u64 couldn't detect an overflow errors (arg > ULLONG_MAX)
>>
>> Signed-off-by: Mr Dash Four <mr.dash.four@googlemail.com>
>>     
>
> I don't demand Developer Certificate of Origin on iproute2 patches.
> But if you are going to include it then you must use your real name,
> no pseudonyms. See kernel/Documentation/SubmittingPatches.
>   
1. You may or may not be aware that this isn't my first-and-only 
contribution to the 
Linux/Netfilter/Security/Audit/kernel/any_other_Linux_development_project_you_care_to_mention 
tree in which I used my name above.
2. How do you know that Dash Four isn't my name and is a "pseudonym" (do 
you consider the name "Dotcom" not to be a real name too, simply because 
in your, quite narrow-minded, understanding of the world this name 
"looks a bit strange, therefore it must be a pseudonym")?
3. The above text you were kind enough to point me to, is with regards 
to kernel submissions. My patch does not alter the kernel tree in any 
way whatsoever (but even if it has, see 1. above).
