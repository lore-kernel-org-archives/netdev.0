From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] cfg80211: fix missing break in NL8211_CHAN_WIDTH_80P80
 case
Date: Tue, 02 Aug 2016 09:44:52 +0200
Message-ID: <1470123892.2665.10.camel@sipsolutions.net>
References: <1468781727-9906-1-git-send-email-colin.king@canonical.com>
	 (sfid-20160717_205612_900519_B3D51FBD)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>,
	"David S . Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1468781727-9906-1-git-send-email-colin.king@canonical.com> (sfid-20160717_205612_900519_B3D51FBD)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2016-07-17 at 19:55 +0100, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> The switch on chandef->width is missing a break on the
> NL8211_CHAN_WIDTH_80P80 case; currently we get a WARN_ON when
> center_freq2 is non-zero because of the missing break.
> 
Applied, thanks.

johannes
