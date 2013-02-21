From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: why is it not allowed to add a new socket protocol family as
 an external module?
Date: Thu, 21 Feb 2013 09:19:33 -0600
Message-ID: <51263B05.1060904@genband.com>
References: <5125002D.9080008@genband.com>	<20130220152325.64c57d55@samsung-9>	<51256E02.4080509@genband.com> <20130220.200502.1241369422255314068.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og111.obsmtp.com ([64.18.2.175]:36300 "EHLO
	exprod7og111.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754063Ab3BUPTn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2013 10:19:43 -0500
In-Reply-To: <20130220.200502.1241369422255314068.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/20/2013 07:05 PM, David Miller wrote:
> From: Chris Friesen<chris.friesen@genband.com> Date: Wed, 20 Feb 2013
> 18:44:50 -0600
>
>> On 02/20/2013 05:23 PM, Stephen Hemminger wrote:
>>> On Wed, 20 Feb 2013 10:56:13 -0600 Chris
>>> Friesen<chris.friesen@genband.com>   wrote:
>>>
>>>> Hi,
>>>>
>>>> I was just wondering why the kernel doesn't allow a new
>>>> network protocol family to be loaded as as a kernel module
>>>> built outside the kernel source tree.
>>
>>> If you want an answer, to the question, use a tool like cscope
>>> and learn to read the kernel code. There are several tables of
>>> pointers sized by NPROTO.
>>
>> That's a bit insulting, don't you think?
>
> Absolutely not insulting at all.
>
> The list is _NOT_ a place to go when you're just too damn lazy to
> take the 10 seconds it would have taken to answer your question with
> a quick NPROTO grep on the kernel sources.
>
> Stephen's response to you was therefore %100 appropriate, and I
> would have told you likewise if I had been the first to respond.

As the rest of my reply to Stephen should have made clear, I in fact did 
read the code prior to asking the question.  My question was not about 
the details of the current implementation, but rather the rationale 
behind them.

I'm fully aware that there are statically-sized tables in the current 
code, and thus the current code does not support dynamically adding 
protocols.  However, it would be reasonably straightforward to extend 
the static tables with some form of dynamic data structure to handle 
adding new network protocols at runtime.

If the current restriction is intentional (to minimize the likelihood 
of non-GPL'd network protocols, for instance), then there's no point in 
anyone submitting patches to add support for dynamic network protocols. 
  If it's just because nobody has bothered to do it yet, then it might 
be an interesting project.

Chris
