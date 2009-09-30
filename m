From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH] connector: Allow permission checking in the receiver callbacks
Date: Wed, 30 Sep 2009 15:20:57 +0400
Message-ID: <20090930112057.GA15150@ioremap.net>
References: <1254235692-1631-1-git-send-email-philipp.reisner@linbit.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Lars Ellenberg <lars.ellenberg@linbit.com>,
	Andrew Morton <akpm@linux-foundation.com>
To: Philipp Reisner <philipp.reisner@linbit.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754197AbZI3LU4@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1254235692-1631-1-git-send-email-philipp.reisner@linbit.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Philipp.

On Tue, Sep 29, 2009 at 04:48:07PM +0200, Philipp Reisner (philipp.reisner@linbit.com) wrote:
> Various users of the connector should actually check if the
> sender's capabilities of a netlink/connector packet are
> actually sufficient for the operation they trigger. Up to
> now the connector framework did not allow the kernel side
> receiver to do so.
> 
> This patch set does the groundwork.
> 
> Philipp Reisner (4):
>   connector: Keep the skb in cn_callback_data
>   connector: Provide the sender's credentials to the callback
>   connector/dm: Fixed a compilation warning
>   connector: Removed the destruct_data callback since it is always
>     kfree_skb()

Patches look good to me.
Andrew please apply to the appropriate tree. I do not know whether it is
acceptible now, since it is not a bugfix, but merely a simple cleanup.
Feel free to add my signed off or ack, thank you.

>  Documentation/connector/cn_test.c      |    2 +-
>  Documentation/connector/connector.txt  |    8 ++++----
>  drivers/connector/cn_queue.c           |   12 +++++++-----
>  drivers/connector/connector.c          |   22 ++++++++--------------
>  drivers/md/dm-log-userspace-transfer.c |    3 +--
>  drivers/staging/dst/dcore.c            |    2 +-
>  drivers/staging/pohmelfs/config.c      |    2 +-
>  drivers/video/uvesafb.c                |    2 +-
>  drivers/w1/w1_netlink.c                |    2 +-
>  include/linux/connector.h              |   11 ++++-------
>  10 files changed, 29 insertions(+), 37 deletions(-)

-- 
	Evgeniy Polyakov
