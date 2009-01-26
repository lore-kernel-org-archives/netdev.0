From: Mike Christie <michaelc@cs.wisc.edu>
Subject: Re: [PANIC] lro + iscsi or lro + skb text search causes panic
Date: Mon, 26 Jan 2009 14:54:31 -0600
Message-ID: <497E2307.8020304@cs.wisc.edu>
References: <alpine.WNT.2.00.0901221234420.4188@jbrandeb-desk1.amr.corp.intel.com> <20090122232131.GA22771@gondor.apana.org.au> <4979097B.4040108@cs.wisc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, olaf.kirch@oracle.com, tgraf@suug.ch,
	kkeil@suse.de, "David S. Miller" <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sabe.cs.wisc.edu ([128.105.6.20]:55222 "EHLO sabe.cs.wisc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751500AbZAZUzY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jan 2009 15:55:24 -0500
In-Reply-To: <4979097B.4040108@cs.wisc.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mike Christie wrote:
> Herbert Xu wrote:
>> On Thu, Jan 22, 2009 at 12:55:21PM -0800, Brandeburg, Jesse wrote:
>>> I've filed this bugzilla a while ago.
>>> http://bugzilla.kernel.org/show_bug.cgi?id=11804
>>> now other customers are becoming interested as well
>>
>> Does this patch help?
>>
>> net: Fix frag_list handling in skb_seq_read
>>
>> The frag_list handling was broken ini skb_seq_read:
>>
>> 1) We didn't add the stepped offset when looking at the head
>> are of fragments other than the first.
>>
>> 2) The frag index wasn't reset.
>>
>> This patch fixes both issues.
>>
> 
> Without the patch I do not get the oops Jesse saw. The iscsi driver logs 
> in and I do not see a problem until running IO (scsi read commands). The 
> iscsi code thinks there is a missing packet at the iscsi level and 
> begins recovery at that level.
> 
> With the patch running against linus's git tree, my box locks up. You 
> cannot ping it. I do not get a oops or anything in the logs, and the 
> keyboard does not respond. I will try to get some oops output and more 
> info.
>

I am not able to get anything. Box is gone.

Jesse, without the patch you guys were getting an oops trace right? Did 
you get one with Herbert's patch?
