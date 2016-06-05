From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] net, cls: allow for deleting all filters for
 given parent
Date: Sun, 05 Jun 2016 19:47:19 +0200
Message-ID: <575465A7.4020308@iogearbox.net>
References: <cd8455dfef0cccec5ef0a1ca2d1f678e9397d66e.1465056745.git.daniel@iogearbox.net> <42e1cc6f-ad10-33b7-6722-1416e1b92422@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, john.fastabend@gmail.com,
	jhs@mojatatu.com, netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:40307 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751348AbcFERrZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jun 2016 13:47:25 -0400
In-Reply-To: <42e1cc6f-ad10-33b7-6722-1416e1b92422@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/05/2016 02:53 PM, Sergei Shtylyov wrote:
> On 6/4/2016 7:24 PM, Daniel Borkmann wrote:
[...]
>
>     Need a comment here, something like /* FALL THRU */.

Hmm, not really, I think it's obvious enough.

>> +        default:
>>              return -ENOENT;
>> -        prio = TC_H_MAKE(0x80000000U, 0U);
>> +        }
>>      }
>>
>>      /* Find head of filter chain. */
> [...]
>
> MBR, Sergei
>
