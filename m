From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Please pull 'upstream-jgarzik' branch of wireless-2.6
Date: Tue, 07 Aug 2007 18:21:34 -0400
Message-ID: <46B8F06E.9000604@garzik.org>
References: <20070806201441.GJ6442@tuxdriver.com> <20070806201649.GK6442@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59210 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S937622AbXHGWVi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Aug 2007 18:21:38 -0400
In-Reply-To: <20070806201649.GK6442@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> These are intended for 2.6.24...
> 
> ---
> 
> The following changes since commit fdc8f43b5e49b64b251bb48da95193a13ac0132f:
>   Michael Buesch (1):
>         softmac: Fix deadlock of wx_set_essid with assoc work
> 
> are available in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream-jgarzik
> 
> Bill Nottingham (1):
>       remove gratuitous space in airo module description
> 
> Faidon Liambotis (2):
>       Kconfig: order options
>       Kconfig: remove references of pcmcia-cs
> 
> Mariusz Kozlowski (1):
>       drivers/net/wireless/prism54/oid_mgt.c: kmalloc + memset conversion to kzalloc
> 
> Matthias Kaehlcke (1):
>       Use mutex instead of semaphore in the Host AP driver
> 
> Ulrich Kunitz (1):
>       zd1211rw: monitor all packets
> 
> Yoann Padioleau (1):
>       dev->priv to netdev_priv(dev), for drivers/net/wireless
> 
>  drivers/net/wireless/Kconfig               |   85 +++++++++++----------------
>  drivers/net/wireless/airo.c                |    4 +-
>  drivers/net/wireless/arlan-proc.c          |   14 ++--
>  drivers/net/wireless/hostap/hostap_cs.c    |    2 +-
>  drivers/net/wireless/hostap/hostap_hw.c    |   16 +++---
>  drivers/net/wireless/hostap/hostap_ioctl.c |   14 ++--
>  drivers/net/wireless/hostap/hostap_wlan.h  |    3 +-
>  drivers/net/wireless/orinoco_tmd.c         |    2 +-
>  drivers/net/wireless/prism54/isl_ioctl.c   |    6 +-
>  drivers/net/wireless/prism54/oid_mgt.c     |    4 +-
>  drivers/net/wireless/ray_cs.c              |   66 +++++++++++-----------
>  drivers/net/wireless/strip.c               |    2 +-
>  drivers/net/wireless/wl3501_cs.c           |   66 +++++++++++-----------
>  drivers/net/wireless/zd1211rw/zd_chip.h    |    5 --
>  drivers/net/wireless/zd1211rw/zd_mac.c     |   44 ++++++++++++--
>  15 files changed, 172 insertions(+), 161 deletions(-)

pulled into #upstream


