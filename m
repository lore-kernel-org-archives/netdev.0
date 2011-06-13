From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH 1/5] iwlegacy: remove unreachable code
Date: Mon, 13 Jun 2011 16:39:23 +0200
Message-ID: <20110613143922.GA8111@redhat.com>
References: <1307066770-27309-1-git-send-email-Gregory.Dietsche@cuw.edu>
 <4DF61E7E.908@cuw.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linville@tuxdriver.com, kernel-janitors@vger.kernel.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Greg Dietsche <gregory.dietsche@cuw.edu>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4DF61E7E.908@cuw.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 13, 2011 at 09:28:14AM -0500, Greg Dietsche wrote:
> On 06/02/2011 09:06 PM, Greg Dietsche wrote:
> >return; at the end of the function is unecessary.
> >
> >Signed-off-by: Greg Dietsche<Gregory.Dietsche@cuw.edu>
> >---
> >  drivers/net/wireless/iwlegacy/iwl-eeprom.c |    1 -
> >  1 files changed, 0 insertions(+), 1 deletions(-)
> >
> >diff --git a/drivers/net/wireless/iwlegacy/iwl-eeprom.c b/drivers/net/wireless/iwlegacy/iwl-eeprom.c
> >index cb346d1..5bf3f49 100644
> >--- a/drivers/net/wireless/iwlegacy/iwl-eeprom.c
> >+++ b/drivers/net/wireless/iwlegacy/iwl-eeprom.c
> >@@ -316,7 +316,6 @@ static void iwl_legacy_init_band_reference(const struct iwl_priv *priv,
> >  		break;
> >  	default:
> >  		BUG();
> >-		return;
> >  	}
> >  }
> >
> 
> any comments/reviews/acks on this patch series?

All 5 patches are applied in wireless-testing tree.

Thanks
Stanislaw
