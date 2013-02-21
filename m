From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: why is it not allowed to add a new socket protocol family as
 an external module?
Date: Wed, 20 Feb 2013 18:44:50 -0600
Message-ID: <51256E02.4080509@genband.com>
References: <5125002D.9080008@genband.com> <20130220152325.64c57d55@samsung-9>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og116.obsmtp.com ([64.18.2.219]:41671 "EHLO
	exprod7og116.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752344Ab3BUApL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2013 19:45:11 -0500
In-Reply-To: <20130220152325.64c57d55@samsung-9>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/20/2013 05:23 PM, Stephen Hemminger wrote:
> On Wed, 20 Feb 2013 10:56:13 -0600
> Chris Friesen<chris.friesen@genband.com>  wrote:
>
>> Hi,
>>
>> I was just wondering why the kernel doesn't allow a new network protocol
>> family to be loaded as as a kernel module built outside the kernel
>> source tree.

> If you want an answer, to the question, use a tool like cscope and
> learn to read the kernel code. There are several tables of pointers sized by NPROTO.

That's a bit insulting, don't you think?

Yes, there are a number of tables sized by NPROTO/AF_MAX/PF_MAX (and the 
fact that we use all three within the kernel is kind of sad) but there 
is no technical reason why we couldn't extend those dynamically if 
desired (with a linked list of additional protocols, perhaps).

Hence my question--is the restriction for an ideological reason or 
simply because nobody thought it was worth the effort?

Chris
