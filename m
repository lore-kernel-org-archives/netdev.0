From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] vhost: drop hard-coded num_buffers size
Date: Thu, 26 Feb 2015 09:21:33 +0100
Message-ID: <20150226082133.GA24138@redhat.com>
References: <1424795457-6770-1-git-send-email-mst@redhat.com>
 <20150225.165652.1024024652864456838.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150225.165652.1024024652864456838.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 25, 2015 at 04:56:52PM -0500, David Miller wrote:
> From: "Michael S. Tsirkin" <mst@redhat.com>
> Date: Tue, 24 Feb 2015 17:31:10 +0100
> 
> > The 2 that we use for copy_to_iter comes from sizeof(u16),
> > it used to be that way before the iov iter update.
> > Fix it up, making it obvious the size of stack access
> > is right.
> > 
> > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> 
> Michael, what tree do you want these two patches to go through?

Sorry about being unclear.
They are net specific so I'd like them merged for 4.0 through net tree.
If that's a problem, pls let me know.

Thanks,
-- 
MST
