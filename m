From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH 1/1] net: sctp: bug fixing when sctp path recovers
Date: Wed, 13 Nov 2013 16:39:34 -0500
Message-ID: <5283F196.9080808@gmail.com>
References: <1384306486-31345-1-git-send-email-changxiangzhong@gmail.com> <5282E5F9.5000506@gmail.com> <5282E9EC.3090307@gmail.com> <52833BD3.4040003@redhat.com> <5283CDD1.3090309@gmail.com> <5283CEC3.4050507@redhat.com> <5283E5A8.3020809@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, davem@davemloft.net,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, dreibh@simula.no
To: Chang <changxiangzhong@gmail.com>,
	Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f51.google.com ([209.85.216.51]:63476 "EHLO
	mail-qa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750874Ab3KMVjj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 16:39:39 -0500
In-Reply-To: <5283E5A8.3020809@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/13/2013 03:48 PM, Chang wrote:
>
> On 11/13/2013 08:10 PM, Daniel Borkmann wrote:
>> On 11/13/2013 08:06 PM, Chang wrote:
>>> On 11/13/2013 09:44 AM, Daniel Borkmann wrote:
>>>> On 11/13/2013 03:54 AM, Chang wrote:
>>>>> On 11/13/2013 03:37 AM, Vlad Yasevich wrote:
>>>>>> On 11/12/2013 08:34 PM, Chang Xiangzhong wrote:
>>>>>>> Look for the __two__ most recently used path/transport and set to
>>>>>>> active_path
>>>>>>> and retran_path respectively
>>>>
>>>> Please also for the log, elaborate a bit more, explaining what
>>>> currently
>>>> happens, and what the effects of this bug are, so that later when
>>>> people
>>>> are looking through the Git log they can easily get what problem you
>>>> are
>>>> trying to fix; and if possible, add:
>>>>
>>>> Fixes: <12 digits SHA1> ("<commit title>")
>>>>
>>> Yeah, sure, I'll elaborate that more specifically.
>>
>> Thanks !
>>
>>> I assume the 12-digit SHA1 is the revision number. But may I ask
>>> where and how shall I add the tag "Fixes" tag? The revision number is
>>> generated after "git commit", how can I know that in advance?
>>
>> Nope, it's the affected commit id from the current git log that
>> your patch fixes.
>>
>> Have a look for example at commit:
>>
>> 98bbc06aabac5a2 ("net: x86: bpf: don't forget to free sk_filter (v2)")
> Thank you for your quick response. I'm quite green on kernel programming
> and git. So here's one question:
> To find the the revision that **caused** the bug, I could use gitk to
> trace the changing of the file(s) history. Is that correct?
>

A lot easier is to run 'git blame <filename>" and find the line you
are fixing.  The number that line starts with is the short commit id.

In this particular case, don't worry about it.  This is a day 1 bug

-vlad
