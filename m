From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vhost: fix performance on LE hosts
Date: Tue, 27 Oct 2015 06:32:55 -0700 (PDT)
Message-ID: <20151027.063255.1140860748569110696.davem@davemloft.net>
References: <1445938640-32673-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, gkurz@linux.vnet.ibm.com,
	kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org
To: mst@redhat.com
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1445938640-32673-1-git-send-email-mst@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Tue, 27 Oct 2015 11:37:39 +0200

> commit 2751c9882b947292fcfb084c4f604e01724af804 ("vhost: cross-endian
> support for legacy devices") introduced a minor regression: even with
> cross-endian disabled, and even on LE host, vhost_is_little_endian is
> checking is_le flag so there's always a branch.
> 
> To fix, simply check virtio_legacy_is_little_endian first.
> 
> Cc: Greg Kurz <gkurz@linux.vnet.ibm.com>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

Michael, do you want me to take this via the 'net' tree?
