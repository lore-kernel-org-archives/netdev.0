From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: virtio-net: why not always to set avail->flags to VRING_AVAIL_F_NO_INTERRUPT
Date: Thu, 04 Jun 2015 10:43:43 +0930
Message-ID: <87k2vkuvg8.fsf@rustcorp.com.au>
References: <556E9F87.7030202@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: virtualization@lists.linux-foundation.org,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Linhaifeng <haifeng.lin@huawei.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:36589 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751043AbbFDB7G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jun 2015 21:59:06 -0400
In-Reply-To: <556E9F87.7030202@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Linhaifeng <haifeng.lin@huawei.com> writes:
> Hi,
>
> I'm a newbie and have a question about vring_new_virtqueue function.
>
> Why we set avail->flags to VRING_AVAIL_F_NO_INTERRUPT when no callbacks?
> I think we should set avail->flags to VRING_AVAIL_F_NO_INTERRUPT even if no callbacks.

Hi Linhaifeng,

        Not sure I understand your question, but I'll try to answer.

We don't set VRING_AVAIL_F_NO_INTERRUPT if there's a callback because we
want that callback called.  Otherwise callback will never be used.

Cheers,
Rusty.
