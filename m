From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: Re: vhost: build failure
Date: Wed, 16 Sep 2015 15:20:13 +0530
Message-ID: <20150916095013.GA4326@sudip-pc>
References: <20150916082008.GA28512@sudip-pc>
 <20150916112119-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150916112119-mutt-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 16, 2015 at 11:36:45AM +0300, Michael S. Tsirkin wrote:
> On Wed, Sep 16, 2015 at 01:50:08PM +0530, Sudip Mukherjee wrote:
> > Hi,
> > While crosscompiling the kernel for openrisc with allmodconfig the build
> > failed with the error:
> > drivers/vhost/vhost.c: In function 'vhost_vring_ioctl':
> > drivers/vhost/vhost.c:818:3: error: call to '__compiletime_assert_818' declared with attribute error: BUILD_BUG_ON failed: __alignof__
> > *vq->avail > VRING_AVAIL_ALIGN_SIZE
> > 
> > Can you please give me any idea about what the problem might be and how
> > it can be solved.
> > 
> > You can see the build log at:
> > https://travis-ci.org/sudipm-mukherjee/parport/jobs/80365425
> > 
> > regards
> > sudip
> 
> Yes - I think I saw this already.
> I think the openrisc cross-compiler is broken.
I thought so. Thanks for the quick reply. I will open a bug in gcc and
lets see what they say.

regards
sudip
