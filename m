From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH for-3.19] vhost/net: fix up num_buffers endian-ness
Date: Wed, 4 Feb 2015 23:45:36 +0000
Message-ID: <20150204234536.GL29656@ZenIV.linux.org.uk>
References: <1422896842-19186-1-git-send-email-mst@redhat.com>
	<20150204.135942.127858058517785730.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20150204.135942.127858058517785730.davem@davemloft.net>
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

On Wed, Feb 04, 2015 at 01:59:42PM -0800, David Miller wrote:
> From: "Michael S. Tsirkin" <mst@redhat.com>
> Date: Tue, 3 Feb 2015 11:07:06 +0200
> 
> > In virtio 1.0 mode, when mergeable buffers are enabled on a big-endian
> > host, num_buffers wasn't byte-swapped correctly, so large incoming
> > packets got corrupted.
> > 
> > To fix, fill it in within hdr - this also makes sure it gets
> > the correct type.
> > 
> > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> 
> Applied.

FWIW, conflict with iov_iter patches is trivial; once it shows up in
your kernel.org tree I can either rebase the series or just push
#merge-candidate - whichever you prefer.  Linus usually prefers the
second variant, but then he seriously dislikes rebasing of any sort;
I've no idea what your preferences are in that area...
