From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] wireless: Use bool function returns of
 true/false instead of 1/0
Date: Sun, 29 Mar 2015 18:49:01 -0700
Message-ID: <1427680141.2715.60.camel@perches.com>
References: <201503260524.AdqSbov9%fengguang.wu@intel.com>
	 <20150325215525.GA26868@athens>
	 <20150329.121655.2092434262655191613.davem@davemloft.net>
	 <1427678712.2715.52.camel@perches.com>
	 <1427678982.2715.55.camel@perches.com> <5518AAFD.1050202@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Stefano Brivio <stefano.brivio@polimi.it>,
	Kalle Valo <kvalo@codeaurora.org>,
	Brett Rudley <brudley@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	Johannes Berg <johannes.berg@intel.com>,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	linux-wireless@vger.kernel.org, b43-dev@lists.infradead.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	brcm80211-dev-list <brcm80211-dev-list@broadcom.com>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5518AAFD.1050202@lwfinger.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2015-03-29 at 20:46 -0500, Larry Finger wrote:
> On 03/29/2015 08:29 PM, Joe Perches wrote:
> > Use bool constants as the return values instead of 1 and 0.
> >
> > Signed-off-by: Joe Perches <joe@perches.com>
> > ---
> >> To be honest I'd might rather get bunches of these, there has to be a ton
> >> of them, than a slow trickle of one every few weeks/days.
> >
> > There aren't too many here either...
> >
> >   drivers/net/wireless/b43/dma.c                        | 12 ++++++------
> >   drivers/net/wireless/b43legacy/dma.c                  |  6 +++---
> >   drivers/net/wireless/b43legacy/rfkill.c               |  8 ++++----
> >   drivers/net/wireless/brcm80211/brcmsmac/phy/phy_cmn.c |  2 +-
> >   drivers/net/wireless/brcm80211/brcmsmac/phy/phy_lcn.c |  2 +-
> >   drivers/net/wireless/iwlwifi/iwl-config.h             |  4 ++--
> >   6 files changed, 17 insertions(+), 17 deletions(-)
> 
> Please split these into separate patches for each driver. That way it will be 
> possible to search 'git log' for the contributions to each driver. Otherwise, 
> the patches are OK.

It's still possible.

git log <directory> shows the individual patches.
