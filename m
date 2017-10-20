From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH 0/2] 9p: Fixes for hard-to-hit bugs
Date: Fri, 20 Oct 2017 21:11:25 +0100
Message-ID: <20171020201125.GU21978@ZenIV.linux.org.uk>
References: <20170906145908.8082-1-tuomas@tuxera.com>
 <1506431414.20647.0.camel@tuxera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: v9fs-developer@lists.sourceforge.net,
        Eric Van Hensbergen <ericvh@gmail.com>,
        Ron Minnich <rminnich@sandia.gov>,
        Latchesar Ionkov <lucho@ionkov.net>,
        "David S. Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
To: Tuomas Tynkkynen <tuomas@tuxera.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1506431414.20647.0.camel@tuxera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 26, 2017 at 04:10:14PM +0300, Tuomas Tynkkynen wrote:
> Hi Al,
> 
> On Wed, 2017-09-06 at 17:59 +0300, Tuomas Tynkkynen wrote:
> > These two patches fix two hard-to-hit (but really annoying) bugs in
> > 9p.
> > The first one was posted earlier in February (with one R-b), the
> > second
> > is a new one.
> > 
> > Both of these have had soaking in NixOS distribution kernels for
> > a couple of months with no ill effects.
> > 
> > Tuomas Tynkkynen (2):
> >   fs/9p: Compare qid.path in v9fs_test_inode
> >   net/9p: Switch to wait_event_killable()
> > 
> >  fs/9p/vfs_inode.c      |  3 +++
> >  fs/9p/vfs_inode_dotl.c |  3 +++
> >  net/9p/client.c        |  3 +--
> >  net/9p/trans_virtio.c  | 13 ++++++-------
> >  net/9p/trans_xen.c     |  4 ++--
> >  5 files changed, 15 insertions(+), 11 deletions(-)
> > 
> 
> Could you apply these? Thanks!

I can pick those, or, if you (or somebody else) are willing to actively
maintain a 9p tree, you could start sending straight to Linus - up to
you.
