From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH 1/1] vhost: TX used buffer guest signal accumulation
Date: Fri, 29 Oct 2010 10:12:56 +0200
Message-ID: <20101029081256.GD22688@redhat.com>
References: <1288216693.17571.38.camel@localhost.localdomain>
 <1288240804.14342.1.camel@localhost.localdomain>
 <20101028052021.GD5599@redhat.com>
 <1288294355.11251.20.camel@localhost.localdomain>
 <1288296835.11251.24.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1288296835.11251.24.camel@localhost.localdomain>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 28, 2010 at 01:13:55PM -0700, Shirley Ma wrote:
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
> 
> Thanks
> Shirley

git bisect 2.6.31 2.6.30
and go from here.
