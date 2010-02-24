From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 3/3] vhost: fix get_user_pages_fast error handling
Date: Wed, 24 Feb 2010 09:34:25 +0200
Message-ID: <20100224073424.GC27806@redhat.com>
References: <20100223173952.GC9834@redhat.com>
	<20100223.144235.08984181.davem@davemloft.net>
	<20100224053737.GB27806@redhat.com>
	<20100223.230428.71578656.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: markmc@redhat.com, kvm@vger.kernel.org, quintela@redhat.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        virtualization@lists.osdl.org, avi@redhat.com, herbert.xu@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20100223.230428.71578656.davem@davemloft.net>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 23, 2010 at 11:04:28PM -0800, David Miller wrote:
> From: "Michael S. Tsirkin" <mst@redhat.com>
> Date: Wed, 24 Feb 2010 07:37:37 +0200
> 
> > Dave, so while Rusty's on vacation, what's the best way to get vhost
> > infrastructure fixes in? Are you ok with getting pull requests and
> > merging them into net-next?  That should keep the clutter in your inbox
> > to the minimum.
> > 
> > Of course network changes would still go the usual way.
> 
> Well, who is providing oversight of vhost work while he's
> gone?

My plan was to get peer review of the patches before merging.
So far Juan Quintela and Gleb Natapov gave feedback.

> Has he, implicitly or explicitly, appointed a maintainer
> while he's away?

Implicitly, I guess. He said "if there's an issue Michael Tsirkin is the
best person to resolve it", this was wrt merging his virtio&lguest tree.
He didn't mention vhost, I wrote all of vhost though, there shouldn't be
an issue with that.

-- 
MST
