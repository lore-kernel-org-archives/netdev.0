From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [RFC PATCH 1/1] vhost: TX used buffer guest signal accumulation
Date: Thu, 28 Oct 2010 14:04:38 -0700
Message-ID: <1288299878.30131.2.camel@sridhar.beaverton.ibm.com>
References: <1288216693.17571.38.camel@localhost.localdomain>
	 <1288240804.14342.1.camel@localhost.localdomain>
	 <20101028052021.GD5599@redhat.com>
	 <1288294355.11251.20.camel@localhost.localdomain>
	 <1288296835.11251.24.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1288296835.11251.24.camel@localhost.localdomain>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-10-28 at 13:13 -0700, Shirley Ma wrote:
> On Thu, 2010-10-28 at 12:32 -0700, Shirley Ma wrote:
> > Also I found a big TX regression for old guest and new guest. For old
> > guest, I am able to get almost 11Gb/s for 2K message size, but for the
> > new guest kernel, I can only get 3.5 Gb/s with the patch and same
> > host.
> > I will dig it why. 
> 
> The regression is from guest kernel, not from this patch. Tested 2.6.31
> kernel, it's performance is less than 2Gb/s for 2K message size already.
> I will resubmit the patch for review. 
> 
> I will start to test from 2.6.30 kernel to figure it when TX regression
> induced in virtio_net. Any suggestion which guest kernel I should test
> to figure out this regression?

It would be some change in virtio-net driver that may have improved the
latency of small messages which in turn would have reduced the bandwidth
as TCP could not accumulate and send large packets.

Thanks
Sridhar

