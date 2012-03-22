From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PULL] vhost-net/virtio: fixes for 3.4
Date: Thu, 22 Mar 2012 10:27:19 +0200
Message-ID: <20120322082718.GA11258@redhat.com>
References: <20120320145010.GA31570@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, virtualization@lists.osdl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	levinsasha928@gmail.com, nyh@il.ibm.com, nyh@math.technion.ac.il
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120320145010.GA31570@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 20, 2012 at 04:50:41PM +0200, Michael S. Tsirkin wrote:
> The following changes since commit 5ffca28a4ac7abb8a254fafe6bd03b2f83667df7:
> 
>   Merge git://git.kernel.org/pub/scm/linux/kernel/git/aia21/ntfs (2012-02-27 07:59:33 -0800)
> 
> are available in the git repository at:
> 
>   ra.kernel.org:/pub/scm/linux/kernel/git/mst/vhost.git for_davem
> 
>   (ssh url as git.kernel.org seems down at the moment, when it comes up
>    git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git for_davem
>    should be the equivalent).
> 
> for you to fetch changes up to ea5d404655ba3b356d0c06d6a3c4f24112124522:
> 
>   vhost: fix release path lockdep checks (2012-02-28 09:13:22 +0200)
> 
> ----------------------------------------------------------------
> vhost/virtio: fixes for 3.4
> 
> This includes a couple of vhost-net bugfixes,
> and fixes tools/virtio making it useful again.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> 
> ----------------------------------------------------------------

Dave, just checking - not sure I made it clear that this pull request
is intended to go in through your tree.
If you see any issues pls let me know so I can fix them.
Thanks!

> Michael S. Tsirkin (4):
>       tools/virtio: add linux/module.h stub
>       tools/virtio: add linux/hrtimer.h stub
>       tools/virtio: stub out strong barriers
>       vhost: fix release path lockdep checks
> 
> Nadav Har'El (1):
>       vhost: don't forget to schedule()
> 
>  drivers/vhost/net.c         |    2 +-
>  drivers/vhost/vhost.c       |   11 +++++++----
>  drivers/vhost/vhost.h       |    2 +-
>  tools/virtio/linux/virtio.h |    3 +++
>  4 files changed, 12 insertions(+), 6 deletions(-)
>  create mode 100644 tools/virtio/linux/hrtimer.h
>  create mode 100644 tools/virtio/linux/module.h
