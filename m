From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 2/3] drivers/staging/rtl8192e: Don't pass huge struct
 by value
Date: Fri, 12 Aug 2011 18:25:56 -0500
Message-ID: <4E45B684.6080300@lwfinger.net>
References: <alpine.LNX.2.00.1108130058310.7387@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <gregkh@suse.de>, devel@driverdev.osuosl.org,
	linux-kernel@vger.kernel.org, Mike McCormack <mikem@ring3k.org>,
	Lucas De Marchi <lucas.demarchi@profusion.mobi>,
	Stefan Weil <weil@mail.berlios.de>,
	Andrea Merello <andreamrl@tiscali.it>, netdev@vger.kernel.org
To: Jesper Juhl <jj@chaosbits.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1108130058310.7387@swampdragon.chaosbits.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/12/2011 06:04 PM, Jesper Juhl wrote:
> From: Jesper Juhl<jj@chaosbits.net>
> Date: Sat, 13 Aug 2011 00:52:32 +0200
>
> struct ieee80211_network is fairly large (more than half a kilobyte),
> so let's pass a pointer instead of passing the entire structure by
> value when ieee80211_is_54g() and ieee80211_is_shortslot() need to
> look at a few members.
> Also remove parentheses around the values being returned from those
> two functions - 'return' is not a function.
>
> Signed-off-by: Jesper Juhl<jj@chaosbits.net>
> ---
>   drivers/staging/rtl8192e/ieee80211/ieee80211.h     |    4 ++--
>   .../staging/rtl8192e/ieee80211/ieee80211_softmac.c |   14 +++++++-------
>   2 files changed, 9 insertions(+), 9 deletions(-)

This patch is a good one; however, in Greg's pile of unmerged patches is a 
completely different driver for the RTL8192E. The new driver has the advantage 
of being organized much more like the drivers in rtlwifi. That will make it 
easier to convert to mac80211 and move to mainline.

I also have a lot of unsubmitted patches to clean up the code in the new driver. 
At the moment, it is clear of 'checkpatch -f' errors, and most warnings. In 
addition, many of the sparse warnings are fixed. Once Greg merges the patches 
already submitted, I will send the others.

Larry
