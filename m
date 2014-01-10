From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH net V3 1/2] macvlan: forbid L2 fowarding offload for macvtap
Date: Fri, 10 Jan 2014 09:39:41 -0800
Message-ID: <52D0305D.2000801@intel.com>
References: <1389341906-2367-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com,
	Neil Horman <nhorman@tuxdriver.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:54474 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751208AbaAJRj4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jan 2014 12:39:56 -0500
In-Reply-To: <1389341906-2367-1-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/10/2014 12:18 AM, Jason Wang wrote:
> L2 fowarding offload will bypass the rx handler of real device. This will make
> the packet could not be forwarded to macvtap device. Another problem is the
> dev_hard_start_xmit() called for macvtap does not have any synchronization.
>
> Fix this by forbidding L2 forwarding for macvtap.
>
> Cc: John Fastabend <john.r.fastabend@intel.com>
> Cc: Neil Horman <nhorman@tuxdriver.com>
> Acked-by: Neil Horman <nhorman@tuxdriver.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---

Same thing here tested my l2 forwarding offload use cases
and they still work. Thanks! For net-next we can look at
getting macvtap to work correctly.

Acked-by: John Fastabend <john.r.fastabend@intel.com.com>
