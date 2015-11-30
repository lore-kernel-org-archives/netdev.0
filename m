From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] vhost: replace % with & on data path
Date: Mon, 30 Nov 2015 11:21:32 +0200
Message-ID: <20151130112043-mutt-send-email-mst@redhat.com>
References: <1448872427-11623-1-git-send-email-mst@redhat.com>
	<1448872969.3032.1.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Joe Perches <joe@perches.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <1448872969.3032.1.camel@perches.com>
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

On Mon, Nov 30, 2015 at 12:42:49AM -0800, Joe Perches wrote:
> On Mon, 2015-11-30 at 10:34 +0200, Michael S. Tsirkin wrote:
> > We know vring num is a power of 2, so use &
> > to mask the high bits.
> []
> > diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> []
> > @@ -1366,10 +1366,12 @@ int vhost_get_vq_desc(struct vhost_virtqueue *vq,
> >  	/* Only get avail ring entries after they have been exposed by guest. */
> >  	smp_rmb();
> >  
> > +	}
> 
> ?

Yes, I noticed this - I moved this chunk from the next patch
in my tree by mistake.

Will fix, thanks!

-- 
MST
