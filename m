From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] net: SCTP NULL-pointer dereference problem description
 and fix
Date: Wed, 15 Sep 2010 09:02:56 -0400
Message-ID: <4C90C400.7040405@hp.com>
References: <201009151003.17407.dreibh@iem.uni-due.de> <4C908768.4040502@cn.fujitsu.com> <201009151453.14465.dreibh@iem.uni-due.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Shan Wei <shanwei@cn.fujitsu.com>, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, Martin Becke <martin.becke@uni-due.de>
To: Thomas Dreibholz <dreibh@iem.uni-due.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:13155 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752923Ab0IONDC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Sep 2010 09:03:02 -0400
In-Reply-To: <201009151453.14465.dreibh@iem.uni-due.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/15/2010 08:53 AM, Thomas Dreibholz wrote:
> On Mittwoch 15 September 2010, Shan Wei wrote:
>> Thomas Dreibholz wrote, at 09/15/2010 04:03 PM:
>>> sctp_assoc_update_retran_path() in net/sctp/associola.c may dereference a
>>> NULL-pointer when compiled with SCTP_DEBUG option: t will be NULL if
>>> there is no usable path for retransmission. SCTP_DEBUG_PRINTK_IPADDR()
>>> makes an access to t->ipaddr.v4.sin_port, without checking t before.
>>> t==NULL => oops.
>>>
>>> The patch below against 2.6.36-rc4 (git repository) simply ensures that t
>>> is checked for not being set to NULL before calling
>>> SCTP_DEBUG_PRINTK_IPADDR().
>>
>> This bug has been reported by WeiYongjun and fixed by vlad for several
>> months. About the details see .
>> http://marc.info/?l=linux-sctp&m=127359276009851&w=2
>>
>> But this patch is still in vlad's net-next tree, not in main tree.
>> See the patch:
>> http://git.kernel.org/?p=linux/kernel/git/vxy/lksctp-dev.git;a=commit;h=eb1
>> 639d206320e6a09168d6dd77306eaf5f02582
> 
> This patch resolves the problem. I am using the main tree. The patch should 
> also be applied there.
> 
> 
> Best regards

Yes.  I know.  I've been just touch busy (and not with SCTP pieces) and backlog
is starting to accumulate.
I'll try to push stuff out this week.

-vlad

