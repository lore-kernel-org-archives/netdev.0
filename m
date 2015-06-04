From: Linhaifeng <haifeng.lin@huawei.com>
Subject: Re: virtio-net: why not always to set avail->flags to VRING_AVAIL_F_NO_INTERRUPT
Date: Thu, 4 Jun 2015 10:35:19 +0800
Message-ID: <556FB967.6010103@huawei.com>
References: <556E9F87.7030202@huawei.com> <87k2vkuvg8.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <virtualization@lists.linux-foundation.org>,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Rusty Russell <rusty@rustcorp.com.au>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:27330 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751364AbbFDCfa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 22:35:30 -0400
In-Reply-To: <87k2vkuvg8.fsf@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2015/6/4 9:13, Rusty Russell wrote:
> Linhaifeng <haifeng.lin@huawei.com> writes:
>> Hi,
>>
>> I'm a newbie and have a question about vring_new_virtqueue function.
>>
>> Why we set avail->flags to VRING_AVAIL_F_NO_INTERRUPT when no callbacks?
>> I think we should set avail->flags to VRING_AVAIL_F_NO_INTERRUPT even if no callbacks.
> 
> Hi Linhaifeng,
> 
>         Not sure I understand your question, but I'll try to answer.
> 
> We don't set VRING_AVAIL_F_NO_INTERRUPT if there's a callback because we
> want that callback called.  Otherwise callback will never be used.
> 
> Cheers,
> Rusty.
> 
> 

Hi Rusty,

Thank you for your response.

I mean should we set VRING_AVAIL_F_NO_INTERRUPT when virtqueue is initialized whether there is callback or not?
As it would be set in function virtqueue_disable_cb and virtqueue_enable_cb_prepare later.

Regards,
Haifeng
