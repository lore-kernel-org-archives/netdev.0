From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/2] VIRTIO: Use __skb_queue_purge()
Date: Thu, 22 May 2008 22:18:42 -0400
Message-ID: <48362982.1040205@pobox.com>
References: <483545EF.3070501@cn.fujitsu.com> <200805231154.12188.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Wang Chen <wangchen@cn.fujitsu.com>,
	"David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:36840 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751734AbYEWCSw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2008 22:18:52 -0400
In-Reply-To: <200805231154.12188.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rusty Russell wrote:
> On Thursday 22 May 2008 20:07:43 Wang Chen wrote:
>> Use standard routine for queue purging.
>>
>> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
> 
> Thanks, applied.
> 
> Jeff, I'm planning on final testing of my 4 pending virtio_net patches for 
> 2.6.26 today: if all goes well, I'll send them in a neat batch.

It seemed more applicable as a general netdev cleanup so I also applied 
it :)

In general, regardless of bus topology or whatever, net driver patches 
tend to come in my direction.

	Jeff



