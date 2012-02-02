From: David Miller <davem@davemloft.net>
Subject: Re: [v3.3-rc2+ PATCH] tcp: properly initialize tcp memory limits
Date: Thu, 02 Feb 2012 14:27:29 -0500 (EST)
Message-ID: <20120202.142729.317148369355280290.davem@davemloft.net>
References: <20120202100700.38694.80000.stgit@amd-6168-8-1.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	glommer@parallels.com, mst@redhat.com
To: jasowang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120202100700.38694.80000.stgit@amd-6168-8-1.englab.nay.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jason Wang <jasowang@redhat.com>
Date: Thu, 02 Feb 2012 18:07:00 +0800

> Commit 4acb4190 tries to fix the using uninitialized value
> introduced by commit 3dc43e3,  but it would make the
> per-socket memory limits too small.
> 
> This patch fixes this and also remove the redundant codes
> introduced in 4acb4190.
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Applied.
