From: Latchesar Ionkov <lucho@ionkov.net>
Subject: Re: [PATCH 0/2] 9p: Fixes for hard-to-hit bugs
Date: Thu, 7 Sep 2017 08:49:54 -0600
Message-ID: <CAOha14xxn4btO3Gd=qYj-JGFHvsFqQWJGGjX8HLDRiWAL7fKTA@mail.gmail.com>
References: <20170906145908.8082-1-tuomas@tuxera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Al Viro <viro@zeniv.linux.org.uk>,
        V9FS Developers <v9fs-developer@lists.sourceforge.net>,
        Eric Van Hensbergen <ericvh@gmail.com>,
        Ron Minnich <rminnich@sandia.gov>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel <linux-kernel@vger.kernel.org>,
        netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: Tuomas Tynkkynen <tuomas@tuxera.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170906145908.8082-1-tuomas@tuxera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Acked-by: Latchesar Ionkov <lucho@ionkov.net>

On Wed, Sep 6, 2017 at 8:59 AM, Tuomas Tynkkynen <tuomas@tuxera.com> wrote:
> These two patches fix two hard-to-hit (but really annoying) bugs in 9p.
> The first one was posted earlier in February (with one R-b), the second
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
> --
> 2.13.0
>
