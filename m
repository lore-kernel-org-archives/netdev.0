From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vhost: fix performance on LE hosts
Date: Tue, 27 Oct 2015 20:19:19 -0700 (PDT)
Message-ID: <20151027.201919.383313270896131203.davem@davemloft.net>
References: <1445938640-32673-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org
To: mst@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1445938640-32673-1-git-send-email-mst@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
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

Applied.
