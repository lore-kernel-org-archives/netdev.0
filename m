From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vhost: drop hard-coded num_buffers size
Date: Wed, 25 Feb 2015 16:56:52 -0500 (EST)
Message-ID: <20150225.165652.1024024652864456838.davem@davemloft.net>
References: <1424795457-6770-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1424795457-6770-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Tue, 24 Feb 2015 17:31:10 +0100

> The 2 that we use for copy_to_iter comes from sizeof(u16),
> it used to be that way before the iov iter update.
> Fix it up, making it obvious the size of stack access
> is right.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

Michael, what tree do you want these two patches to go through?
