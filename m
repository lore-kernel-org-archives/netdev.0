From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xen: netback: remove redundant xenvif_put
Date: Tue, 19 Feb 2013 00:53:56 -0500 (EST)
Message-ID: <20130219.005356.2288460992654639558.davem@davemloft.net>
References: <1361219360-29176-1-git-send-email-drjones@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xensource.com, ian.campbell@citrix.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: drjones@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1361219360-29176-1-git-send-email-drjones@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Jones <drjones@redhat.com>
Date: Mon, 18 Feb 2013 21:29:20 +0100

> netbk_fatal_tx_err() calls xenvif_carrier_off(), which does
> a xenvif_put(). As callers of netbk_fatal_tx_err should only
> have one reference to the vif at this time, then the xenvif_put
> in netbk_fatal_tx_err is one too many.
> 
> Signed-off-by: Andrew Jones <drjones@redhat.com>

Applied.
