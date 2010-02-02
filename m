From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 0/2] virtio net improvements
Date: Wed, 3 Feb 2010 09:57:06 +1030
Message-ID: <201002030957.06307.rusty@rustcorp.com.au>
References: <201001292346.43675.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	virtualization@lists.linux-foundation.org,
	Shirley Ma <mashirle@us.ibm.com>,
	"Michael S. Tsirkin" <mst@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:49485 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755180Ab0BBX1R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2010 18:27:17 -0500
In-Reply-To: <201001292346.43675.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 29 Jan 2010 11:46:43 pm Rusty Russell wrote:
> Hi Dave,
> 
>    Nice driver optimization from Shirley, but requires a new virtio hook.
> Do you want to take both?  I have nothing else overlapping it.

Dave, any news on this?  Shirley, I note that your final commit message did
not contain this information from your original version:

	Tests have been done for small packets, big packets and
	mergeable buffers.

	The single netperf TCP_STREAM performance improved for host to guest. 
	It also reduces UDP packets drop rate.

	The netperf laptop results were:

	mtu=1500
	netperf -H xxx -l 120

	                w/o patch       w/i patch (two runs)    
	guest to host:  3336.84Mb/s   3730.14Mb/s ~ 3582.88Mb/s

	host to guest:  3165.10Mb/s   3370.39Mb/s ~ 3407.96Mb/s

Thanks,
Rusty.
