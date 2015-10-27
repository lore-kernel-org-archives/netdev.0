From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] vhost: fix performance on LE hosts
Date: Tue, 27 Oct 2015 17:52:24 +0200
Message-ID: <20151027175057-mutt-send-email-mst@redhat.com>
References: <1445938640-32673-1-git-send-email-mst@redhat.com>
	<20151027.063255.1140860748569110696.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20151027.063255.1140860748569110696.davem@davemloft.net>
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

On Tue, Oct 27, 2015 at 06:32:55AM -0700, David Miller wrote:
> From: "Michael S. Tsirkin" <mst@redhat.com>
> Date: Tue, 27 Oct 2015 11:37:39 +0200
> 
> > commit 2751c9882b947292fcfb084c4f604e01724af804 ("vhost: cross-endian
> > support for legacy devices") introduced a minor regression: even with
> > cross-endian disabled, and even on LE host, vhost_is_little_endian is
> > checking is_le flag so there's always a branch.
> > 
> > To fix, simply check virtio_legacy_is_little_endian first.
> > 
> > Cc: Greg Kurz <gkurz@linux.vnet.ibm.com>
> > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> 
> Michael, do you want me to take this via the 'net' tree?

Sure - especially since it looks like I have nothing else for this merge
window (working on fixing shutdown races, but it's slow going).  Thanks
a lot!

-- 
MST
