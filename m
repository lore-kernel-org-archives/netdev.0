From: "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: Re: [PULL] vhost: cleanups and fixes for 3.10
Date: Wed, 01 May 2013 09:05:35 -0700
Message-ID: <1367424335.10977.2.camel@haakon3.risingtidesystems.com>
References: <20130501150130.GA21230@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, asias@redhat.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linux-iscsi.org ([67.23.28.174]:45410 "EHLO
	linux-iscsi.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756889Ab3EAQDN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 May 2013 12:03:13 -0400
In-Reply-To: <20130501150130.GA21230@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-05-01 at 18:01 +0300, Michael S. Tsirkin wrote:
> Please pull the following vhost core updates for 3.10 -
> they affect both vhost-net and vhost-scsi devices.
> They also *depend* on both net-next and target-pending.  Since Linus
> merged target-pending but not net-next at this point, merging through
> the net tree seems to make sense.
> 

Perfectly fine by me..

Btw, I'll be sending another PULL request next week for some other minor
-rc1 items, so if DaveM prefers I'm happy to include this series in that
PULL instead.

--nab

> The following changes since commit bc7562355fda8075793bf66094cda573206ec693:
> 
>   Merge branch 'for-next-merge' of git://git.kernel.org/pub/scm/linux/kernel/git/nab/target-pending into vhost-net-next (2013-05-01 09:16:50 +0300)
> 
> are available in the git repository at:
> 
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git vhost-net-next
> 
> for you to fetch changes up to 150b9e51ae975ca1fe468c565870fbc4a96e0574:
> 
>   vhost: fix error handling in RESET_OWNER ioctl (2013-05-01 10:02:54 +0300)
> 
> ----------------------------------------------------------------
> Asias He (3):
>       vhost: Allow device specific fields per vq
>       tcm_vhost: Wait for pending requests in vhost_scsi_flush()
>       vhost: move vhost-net zerocopy fields to net.c
> 
> Michael S. Tsirkin (4):
>       tcm_vhost: document inflight ref-counting use
>       vhost: move per-vq net specific fields out to net
>       tcm_vhost: remove virtio-net.h dependency
>       vhost: fix error handling in RESET_OWNER ioctl
> 
>  drivers/vhost/net.c       | 255 ++++++++++++++++++++++++++++++++++++----------
>  drivers/vhost/tcm_vhost.c | 154 ++++++++++++++++++++++++----
>  drivers/vhost/tcm_vhost.h |   3 +
>  drivers/vhost/test.c      |   9 +-
>  drivers/vhost/vhost.c     | 153 +++++++++-------------------
>  drivers/vhost/vhost.h     |  32 +-----
>  6 files changed, 400 insertions(+), 206 deletions(-)
