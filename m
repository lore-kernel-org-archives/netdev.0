From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PULL] virtio: fixes, tests
Date: Wed, 27 Jan 2016 11:57:52 -0800
Message-ID: <CA+55aFzypP2SDdX7y8MpZGKhmLJot=UT4i328CYBcNQsP2VU+Q@mail.gmail.com>
References: <20160127211216-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jmarchan@redhat.com, KVM list <kvm@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Kamal Mostafa <kamal@canonical.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	virtualization <virtualization@lists.linux-foundation.org>,
	Sasha Levin <sasha.levin@oracle.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20160127211216-mutt-send-email-mst@redhat.com>
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

On Wed, Jan 27, 2016 at 11:12 AM, Michael S. Tsirkin <mst@redhat.com> wrote:
>
>  arch/sh/include/asm/barrier.h            |   1 -
>  tools/virtio/asm/barrier.h               |  22 +-
>  tools/virtio/linux/compiler.h            |   9 +
>  tools/virtio/linux/kernel.h              |   1 +
>  tools/virtio/ringtest/main.h             | 119 ++++++++++
>  drivers/virtio/virtio_pci_common.c       |   2 +
>  tools/virtio/ringtest/main.c             | 366 +++++++++++++++++++++++++++++++
>  tools/virtio/ringtest/ring.c             | 272 +++++++++++++++++++++++
>  tools/virtio/ringtest/virtio_ring_0_9.c  | 316 ++++++++++++++++++++++++++
>  tools/virtio/ringtest/virtio_ring_poll.c |   2 +
>  tools/virtio/ringtest/Makefile           |  22 ++
>  tools/virtio/ringtest/README             |   2 +
>  tools/virtio/ringtest/run-on-all.sh      |  24 ++
>  13 files changed, 1148 insertions(+), 10 deletions(-)

How the heck did you generate that diffstat? The names should be
ordered, and are for me.

Anyway, pulled. Just curious about how that thing happened.

             Linus
