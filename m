From: Wanlong Gao <gaowanlong@cn.fujitsu.com>
Subject: Re: [PATCH V6 1/3] virtio-net: fix the set affinity bug when CPU
 IDs are not consecutive
Date: Thu, 24 Jan 2013 10:28:55 +0800
Message-ID: <51009C67.3090809@cn.fujitsu.com>
References: <1358767524-17934-1-git-send-email-gaowanlong@cn.fujitsu.com> <87hamavx4n.fsf@rustcorp.com.au>
Reply-To: gaowanlong@cn.fujitsu.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	linux-kernel@vger.kernel.org, Jason Wang <jasowang@redhat.com>,
	Eric Dumazet <erdnetdev@gmail.com>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:2575 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752988Ab3AXCeA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2013 21:34:00 -0500
In-Reply-To: <87hamavx4n.fsf@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/22/2013 09:12 AM, Rusty Russell wrote:
> Wanlong Gao <gaowanlong@cn.fujitsu.com> writes:
> 
>> As Michael mentioned, set affinity and select queue will not work very
>> well when CPU IDs are not consecutive, this can happen with hot unplug.
>> Fix this bug by traversal the online CPUs, and create a per cpu variable
>> to find the mapping from CPU to the preferable virtual-queue.
> 
> This series looks fairly sane at a glance, to me, but MST is the Ack you
> need.

Hi Michael,

Any comments?

Thanks,
Wanlong Gao

> 
> Thanks,
> Rusty.
> 
