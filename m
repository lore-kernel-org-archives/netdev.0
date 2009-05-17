From: Avi Kivity <avi@redhat.com>
Subject: Re: [PATCH 2/3] virtio: indirect ring entries (VIRTIO_RING_F_INDIRECT_DESC)
Date: Sun, 17 May 2009 09:27:01 +0300
Message-ID: <4A0FAE35.3040608@redhat.com>
References: <1229620222-22216-1-git-send-email-markmc@redhat.com> <200905041149.00724.rusty@rustcorp.com.au> <1242061838.25337.8.camel@blaa> <200905171134.31285.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mark McLoughlin <markmc@redhat.com>, dlaor@redhat.com,
	netdev@vger.kernel.org, Dor Laor <dor@redhat.com>,
	virtualization@lists.linux-foundation.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:38819 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750724AbZEQG1Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 May 2009 02:27:16 -0400
In-Reply-To: <200905171134.31285.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rusty Russell wrote:
>  
> +static void adjust_threshold(struct vring_virtqueue *vq,
> +			     unsigned int out, unsigned int in)
> +{
> +	/* There are really two species of virtqueue, and it matters here.
> +	 * If there are no output parts, it's a "normally full" receive queue,
> +	 * otherwise it's a "normally empty" send queue. */
>   

This comment is true for networking, but not for block. ++overkill with 
a ->adjust_threshold op.

-- 
Do not meddle in the internals of kernels, for they are subtle and quick to panic.

