From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PULL] virtio: virtio 1.0 support, misc patches
Date: Fri, 12 Dec 2014 00:01:57 +0200
Message-ID: <20141211220157.GA22618@redhat.com>
References: <20141211120248.GA8838@redhat.com>
	<20141212080705.50988d51@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, kvm@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	pbonzini@redhat.com, ben@decadent.org.uk,
	David Miller <davem@davemloft.net>, thuth@linux.vnet.ibm.com
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20141212080705.50988d51@canb.auug.org.au>
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

On Fri, Dec 12, 2014 at 08:07:05AM +1100, Stephen Rothwell wrote:
> Hi Michael,
> 
> On Thu, 11 Dec 2014 14:02:48 +0200 "Michael S. Tsirkin" <mst@redhat.com> wrote:
> >
> > The following changes since commit b2776bf7149bddd1f4161f14f79520f17fc1d71d:
> > 
> >   Linux 3.18 (2014-12-07 14:21:05 -0800)
> 
> hmmm ...
> 
> > are available in the git repository at:
> > 
> >   git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git tags/for_linus
> > 
> > for you to fetch changes up to 803cd18f7b5e6c7ad6bee9571ae8f4450190ab58:
> > 
> >   virtio_ccw: finalize_features error handling (2014-12-09 16:32:41 +0200)
> > 
> > Note: some net drivers are affected by these patches.
> > David said he's fine with merging these patches through
> > my tree.
> > Rusty's on vacation, he acked using my tree for these, too.
> 
> So, either none of this has been in linux-next or you have just rebased
> it all on top of v3.18 ...

It was on linux next for a while, then I wanted to tweak the commit log
for some messages a bit.
So since I rewrote the history anyway, I went ahead and rebased it
on v3.18, after this rebase it's been in linux-next for several days.

> -- 
> Cheers,
> Stephen Rothwell                    sfr@canb.auug.org.au
