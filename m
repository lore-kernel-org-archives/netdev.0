From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] net, cls: allow for deleting all filters for
 given parent
Date: Mon, 6 Jun 2016 19:41:16 +0300
Message-ID: <f2e1eb44-a0ef-5b41-2dc0-6823cbe4f392@cogentembedded.com>
References: <cd8455dfef0cccec5ef0a1ca2d1f678e9397d66e.1465056745.git.daniel@iogearbox.net>
 <42e1cc6f-ad10-33b7-6722-1416e1b92422@cogentembedded.com>
 <575465A7.4020308@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, john.fastabend@gmail.com,
	jhs@mojatatu.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f51.google.com ([209.85.215.51]:33081 "EHLO
	mail-lf0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752086AbcFFQlX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 12:41:23 -0400
Received: by mail-lf0-f51.google.com with SMTP id s64so98479707lfe.0
        for <netdev@vger.kernel.org>; Mon, 06 Jun 2016 09:41:20 -0700 (PDT)
In-Reply-To: <575465A7.4020308@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/05/2016 08:47 PM, Daniel Borkmann wrote:

>> On 6/4/2016 7:24 PM, Daniel Borkmann wrote:
> [...]
>>
>>     Need a comment here, something like /* FALL THRU */.
>
> Hmm, not really, I think it's obvious enough.

    Well, at least the *switch* example in the CodingStyle chapter 1 has such 
comment (though there's no explicit statement on this matter).

>>> +        default:
>>>              return -ENOENT;
>>> -        prio = TC_H_MAKE(0x80000000U, 0U);
>>> +        }
>>>      }
[...]

MBR, Sergei
