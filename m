From: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [GIT PULL 0/5] IEEE 802.15.4 last-minute
	fixes.
Date: Tue, 4 Aug 2009 18:48:10 +0400
Message-ID: <20090804144810.GA23722@doriath.ww600.siemens.net>
References: <1249339902-10613-1-git-send-email-dbaryshkov@gmail.com>
	<20090803.193546.102476162.davem@davemloft.net>
	<20090804085147.GA6724@doriath.ww600.siemens.net>
	<20090804.055810.201482741.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090804.055810.201482741.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 04, 2009 at 05:58:10AM -0700, David Miller wrote:
> From: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date: Tue, 4 Aug 2009 12:51:48 +0400
> 
> > Will you pull the serie if I'll remove those two patches? Documentation
> > fix isn't that important, however I'd really ask to pull the remaining
> > two patches.
> 
> Yes.

Pushed the updated branch. Please pull.

The following changes since commit e4c4e448cf557921ffbbbd6d6ddac81fdceacb4f:
  Eric Dumazet (1):
        neigh: Convert garbage collection from softirq to workqueue

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/lowpan/lowpan.git for-linus

Dmitry Eremin-Solenikov (3):
      af_ieee802154: fix ioctl processing
      af_ieee802154: provide dummy get/setsockopt
      documentation: fix wrt. headers rename

 Documentation/networking/ieee802154.txt |    9 ++++-----
 net/ieee802154/af_ieee802154.c          |    8 +++++---
 net/ieee802154/dgram.c                  |   14 ++++++++++++++
 net/ieee802154/raw.c                    |   14 ++++++++++++++
 4 files changed, 37 insertions(+), 8 deletions(-)

-- 
With best wishes
Dmitry


------------------------------------------------------------------------------
Let Crystal Reports handle the reporting - Free Crystal Reports 2008 30-Day 
trial. Simplify your report design, integration and deployment - and focus on 
what you do best, core application coding. Discover what's new with 
Crystal Reports now.  http://p.sf.net/sfu/bobj-july
