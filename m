From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [RFC PATCH 1/1] vhost: TX used buffer guest signal accumulation
Date: Thu, 28 Oct 2010 14:40:50 -0700
Message-ID: <1288302050.11251.26.camel@localhost.localdomain>
References: <1288216693.17571.38.camel@localhost.localdomain>
	 <1288240804.14342.1.camel@localhost.localdomain>
	 <20101028052021.GD5599@redhat.com>
	 <1288294355.11251.20.camel@localhost.localdomain>
	 <1288296835.11251.24.camel@localhost.localdomain>
	 <1288299878.30131.2.camel@sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1288299878.30131.2.camel@sridhar.beaverton.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-10-28 at 14:04 -0700, Sridhar Samudrala wrote:
> It would be some change in virtio-net driver that may have improved
> the
> latency of small messages which in turn would have reduced the
> bandwidth
> as TCP could not accumulate and send large packets.

I will check out any latency improvement patch in virtio_net. If that's
the case, whether it is good to have some tunable parameter to benefit
both BW and latency workload?

Shirley 
