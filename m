From: Jim Cromie <jim.cromie@gmail.com>
Subject: Re: [PATCH 00/10] dynamic_debug: various fixes
Date: Wed, 6 Jul 2011 11:57:21 -0600
Message-ID: <CAJfuBxyfA=Hjr8HEp47mKyr9fSdRGhppKr_-755vHQqn_RB=8Q@mail.gmail.com>
References: <cover.1309967232.git.root@dhcp-100-18-164.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: gregkh@suse.de, joe@perches.com, bvanassche@acm.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	aloisio.almeida@openbossa.org, netdev@vger.kernel.org
To: Jason Baron <jbaron@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1309967232.git.root@dhcp-100-18-164.bos.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 6, 2011 at 11:24 AM, Jason Baron <jbaron@redhat.com> wrote:
> Hi,
>
> Various dynamic debug fixes and cleanups, and a patch to add myself a=
s
> maintainer. Hopefully, nobody will object too loudly :)
>

do you have this in a git-tree somewhere I can pull ?

> Thanks,
>
> -Jason
>
>
> Joe Perches (4):
> =A0dynamic_debug: Add __dynamic_dev_dbg
> =A0dynamic_debug: Consolidate prefix output to single routine
> =A0dynamic_debug: Remove uses of KERN_CONT in dynamic_emit_prefix
> =A0dynamic_debug: Convert printks to pr_<level>
>
> Jason Baron (6):
> =A0dynamic_debug: remove unused control variables
> =A0dynamic_debug: add myslef as maintainer
> =A0dynamic_debug: make netdev_dbg() call __netdev_printk()
> =A0dynamic_debug: make netif_dbg() call __netdev_printk()
> =A0dynamic_debug: consolidate repetitive struct _ddebug descriptor
> =A0 =A0definitions
> =A0dynamic_debug: remove num_enabled accounting
>
> =A0MAINTAINERS =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A06 ++
> =A0drivers/base/core.c =A0 =A0 =A0 =A0 =A0 | =A0 =A05 +-
> =A0include/linux/device.h =A0 =A0 =A0 =A0| =A0 =A05 +
> =A0include/linux/dynamic_debug.h | =A0 58 ++++++++++-----
> =A0include/linux/netdevice.h =A0 =A0 | =A0 12 ++--
> =A0lib/dynamic_debug.c =A0 =A0 =A0 =A0 =A0 | =A0165 +++++++++++++++++=
+++++++++++-------------
> =A0net/core/dev.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A03 +-
> =A07 files changed, 172 insertions(+), 82 deletions(-)
>
> --
> 1.7.5.4
>
>
