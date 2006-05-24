From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Please pull 'upstream' branch of wireless-2.6
Date: Wed, 24 May 2006 00:35:20 -0400
Message-ID: <4473E288.3030005@garzik.org>
References: <20060522191759.GD13964@tuxdriver.com> <20060522191942.GE13964@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41438 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S932183AbWEXEfX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 May 2006 00:35:23 -0400
To: "John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
In-Reply-To: <20060522191942.GE13964@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> The following changes since commit 01d654d25d23fb73deb7904ce1c0b3a0f5fc2908:
>   John W. Linville:
>         Merge branch 'upstream-fixes' into upstream
> 
> are found in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream
> 
> Marcin Juszkiewicz:
>       hostap: new pcmcia IDs
> 
>  drivers/net/wireless/hostap/hostap_cs.c |    6 ++++++
>  1 files changed, 6 insertions(+), 0 deletions(-)

WTF???  I pull, and see diffstat:

Merge db21e578e551421d76641d72cb3f8296ed3f9e61, made by recursive.
  drivers/net/wireless/airo.c                     |    2
  drivers/net/wireless/bcm43xx/bcm43xx_main.c     |    8 +-
  drivers/net/wireless/hostap/hostap_80211_tx.c   |    1
  drivers/net/wireless/hostap/hostap_ap.c         |   11 --
  drivers/net/wireless/hostap/hostap_cs.c         |    6 +
  drivers/net/wireless/hostap/hostap_main.c       |    2
  drivers/net/wireless/orinoco_cs.c               |   33 ++----
  drivers/net/wireless/orinoco_nortel.c           |    5 +
  drivers/net/wireless/orinoco_pci.c              |    5 +
  drivers/net/wireless/orinoco_pci.h              |   31 +-----
  drivers/net/wireless/orinoco_plx.c              |    5 +
  drivers/net/wireless/orinoco_tmd.c              |    5 +
  drivers/net/wireless/spectrum_cs.c              |   33 ++----
  include/net/ieee80211softmac.h                  |   38 ++++++-
  net/ieee80211/ieee80211_wx.c                    |    2
  net/ieee80211/softmac/ieee80211softmac_assoc.c  |   72 +++++++-------
  net/ieee80211/softmac/ieee80211softmac_auth.c   |    3 +
  net/ieee80211/softmac/ieee80211softmac_module.c |  117 
+++++++++++++++++++----
  net/ieee80211/softmac/ieee80211softmac_priv.h   |    6 +
  net/ieee80211/softmac/ieee80211softmac_wx.c     |    6 +
  20 files changed, 228 insertions(+), 163 deletions(-)

This is vastly different from any 'pull upstream' email I've received 
from you.  It is extremely uncool for me to pull, and receive something 
other than what your email specified.

Nonetheless, I looked over the changes and they look OK, so I took the 
lazy route and kept them.

For the future, I would perhaps recommend creating an upstream-jeff 
branch at the time of submission, if you insist upon continuing to push 
stuff into the upstream branch in the window between submission and 
pull.  I do this with Linus:  I create an 'upstream-linus' branch, 
branched off of 'upstream', at the time of submission.  After Linus 
pulls, I delete the branch.

	Jeff

