From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH] virtio: Avoid virtio_net TX queue over run
Date: Thu, 17 Mar 2011 09:50:26 -0700
Message-ID: <1300380626.3255.53.camel@localhost.localdomain>
References: <1300320595.3255.29.camel@localhost.localdomain>
	 <20110317050538.GD32049@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:36516 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751867Ab1CQQue (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Mar 2011 12:50:34 -0400
In-Reply-To: <20110317050538.GD32049@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-03-17 at 07:05 +0200, Michael S. Tsirkin wrote:
> Could you add CPU utilization data pls? I also wonder what does this
> do
> to UDP?  Won't a lot of packets be dropped?

Guest CPU utilization slightly increased a few %.

UDP performance send rate increased 200% - 400%, recv rate increased
from 10% to around 40% w/i recv errors. I will tune the buffers to see
any better.

I am putting all data together and post the results here soon.

Thanks
Shirley

