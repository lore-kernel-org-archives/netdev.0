From: David Dillow <dave@thedillows.org>
Subject: Re: [PATCH 1/2] 3com/typhoon: reuse eth_mac_addr()
Date: Wed, 22 Feb 2012 08:32:17 -0500
Message-ID: <1329917537.27315.0.camel@obelisk.thedillows.org>
References: <1329914199-30862-1-git-send-email-danny.kukawka@bisect.de>
	 <1329914199-30862-2-git-send-email-danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Danny Kukawka <dkukawka@suse.de>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: Danny Kukawka <danny.kukawka@bisect.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1329914199-30862-2-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-02-22 at 13:36 +0100, Danny Kukawka wrote:
> Use eth_mac_addr() for .ndo_set_mac_address, remove
> typhoon_set_mac_address() since it do currently the same as
> eth_mac_addr(). Additional advantage: eth_mac_addr() already
> checks if the given address is valid.
> 
> Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>

Acked-by: Dave Dillow <dave@thedillows.org>
