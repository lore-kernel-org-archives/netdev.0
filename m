From: Avi Kivity <avi@redhat.com>
Subject: Re: [PATCH 2/3] virtio: indirect ring entries (VIRTIO_RING_F_INDIRECT_DESC)
Date: Sun, 17 May 2009 18:05:39 +0300
Message-ID: <4A1027C3.3080109@redhat.com>
References: <1229620222-22216-1-git-send-email-markmc@redhat.com> <200905171134.31285.rusty@rustcorp.com.au> <4A0FAE35.3040608@redhat.com> <200905172346.14498.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mark McLoughlin <markmc@redhat.com>, dlaor@redhat.com,
	netdev@vger.kernel.org, Dor Laor <dor@redhat.com>,
	virtualization@lists.linux-foundation.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:38237 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750829AbZEQPFt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 May 2009 11:05:49 -0400
In-Reply-To: <200905172346.14498.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rusty Russell wrote:
> On Sun, 17 May 2009 03:57:01 pm Avi Kivity wrote:
>   
>> Rusty Russell wrote:
>>     
>>> +static void adjust_threshold(struct vring_virtqueue *vq,
>>> +			     unsigned int out, unsigned int in)
>>> +{
>>> +	/* There are really two species of virtqueue, and it matters here.
>>> +	 * If there are no output parts, it's a "normally full" receive queue,
>>> +	 * otherwise it's a "normally empty" send queue. */
>>>       
>> This comment is true for networking, but not for block. ++overkill with
>> a ->adjust_threshold op.
>>     
>
> No, it's true for block.  It has output parts, so we should reduce threshold 
> when it's full.  Network recvq is an example which should reduce threshold 
> when it's empty.
>   

You mean the header that contains the sector number?  It's a little 
incidental, but I guess it works.

-- 
error compiling committee.c: too many arguments to function

