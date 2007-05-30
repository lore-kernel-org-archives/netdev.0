From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Please pull 'upstream' branch of wireless-2.6
Date: Wed, 30 May 2007 10:03:22 -0400
Message-ID: <465D842A.40105@garzik.org>
References: <20070529183037.GB3496@tuxdriver.com> <20070529183135.GC3496@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:33954 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756132AbXE3ODY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 May 2007 10:03:24 -0400
In-Reply-To: <20070529183135.GC3496@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> The following changes since commit d7ea3be56adc95b17351221fd95e78115f3b01f4:
>   Brandon Craig Rhodes (1):
>         hostap: Allocate enough tailroom for TKIP
> 
> are found in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream
> 
> Akinobu Mita (1):
>       softmac: use list_for_each_entry
> 
> Daniel Drake (4):
>       zd1211rw: Add ID for ZyXEL G-200v2
>       zd1211rw: Extend RF layer
>       zd1211rw: Add UW2453 RF support
>       zd1211rw: Make CCK gain patching conditional on RF type
> 
> Jouni Malinen (1):
>       hostap: Remove driver version number
> 
> Larry Finger (1):
>       bcm43xx: Fix deviation from specifications in set_baseband_attenuation
> 
> Matthias Kaehlcke (1):
>       hostap: Use list_for_each_entry
> 
> Pavel Roskin (1):
>       hostap: Suppress broadcast if no stations are associated
> 
>  drivers/net/wireless/bcm43xx/bcm43xx_phy.c      |    2 +-
>  drivers/net/wireless/hostap/hostap_ap.c         |   34 +-
>  drivers/net/wireless/hostap/hostap_config.h     |    2 -
>  drivers/net/wireless/hostap/hostap_cs.c         |    4 -
>  drivers/net/wireless/hostap/hostap_ioctl.c      |    2 -
>  drivers/net/wireless/hostap/hostap_main.c       |    1 -
>  drivers/net/wireless/hostap/hostap_pci.c        |    5 -
>  drivers/net/wireless/hostap/hostap_plx.c        |    5 -
>  drivers/net/wireless/zd1211rw/Makefile          |    2 +-
>  drivers/net/wireless/zd1211rw/zd_chip.c         |    5 +-
>  drivers/net/wireless/zd1211rw/zd_chip.h         |    3 +
>  drivers/net/wireless/zd1211rw/zd_rf.c           |   21 +-
>  drivers/net/wireless/zd1211rw/zd_rf.h           |   28 ++
>  drivers/net/wireless/zd1211rw/zd_rf_al2230.c    |    1 +
>  drivers/net/wireless/zd1211rw/zd_rf_al7230b.c   |    1 +
>  drivers/net/wireless/zd1211rw/zd_rf_uw2453.c    |  534 +++++++++++++++++++++++
>  drivers/net/wireless/zd1211rw/zd_usb.c          |    1 +
>  net/ieee80211/softmac/ieee80211softmac_module.c |   32 +-
>  18 files changed, 611 insertions(+), 72 deletions(-)
>  create mode 100644 drivers/net/wireless/zd1211rw/zd_rf_uw2453.c

pulled


