From: Tuomas Tynkkynen <tuomas@tuxera.com>
Subject: Re: [PATCH 0/2] 9p: Fixes for hard-to-hit bugs
Date: Fri, 20 Oct 2017 15:34:28 +0300
Message-ID: <1508502868.17067.3.camel@tuxera.com>
References: <20170906145908.8082-1-tuomas@tuxera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <v9fs-developer@lists.sourceforge.net>,
        Eric Van Hensbergen <ericvh@gmail.com>,
        Ron Minnich <rminnich@sandia.gov>,
        Latchesar Ionkov <lucho@ionkov.net>,
        "David S. Miller" <davem@davemloft.net>,
        <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-fsdevel@vger.kernel.org>
To: Al Viro <viro@zeniv.linux.org.uk>,
        Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20170906145908.8082-1-tuomas@tuxera.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Al, Linus

Can one of you please pick these patches? They've been on the list for
a month now, with an ack from Latchesar Ionkov.

Thanks!

Tuomas

On Wed, 2017-09-06 at 17:59 +0300, Tuomas Tynkkynen wrote:
> These two patches fix two hard-to-hit (but really annoying) bugs in
> 9p.
> The first one was posted earlier in February (with one R-b), the
> second
> is a new one.
> 
> Both of these have had soaking in NixOS distribution kernels for
> a couple of months with no ill effects.
> 
> Tuomas Tynkkynen (2):
>   fs/9p: Compare qid.path in v9fs_test_inode
>   net/9p: Switch to wait_event_killable()
> 
>  fs/9p/vfs_inode.c      |  3 +++
>  fs/9p/vfs_inode_dotl.c |  3 +++
>  net/9p/client.c        |  3 +--
>  net/9p/trans_virtio.c  | 13 ++++++-------
>  net/9p/trans_xen.c     |  4 ++--
>  5 files changed, 15 insertions(+), 11 deletions(-)
> 
