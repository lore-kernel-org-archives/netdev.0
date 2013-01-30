From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] nl80211: avoid "wdev_id may be used uninitialized"
Date: Wed, 30 Jan 2013 08:57:59 +0100
Message-ID: <1359532679.8010.1.camel@jlt4.sipsolutions.net>
References: <1359504662-23561-1-git-send-email-swarren@wwwdotorg.org>
	 (sfid-20130130_011118_335925_03B80596)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Stephen Warren <swarren@nvidia.com>
To: Stephen Warren <swarren@wwwdotorg.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1359504662-23561-1-git-send-email-swarren@wwwdotorg.org> (sfid-20130130_011118_335925_03B80596)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-01-29 at 17:11 -0700, Stephen Warren wrote:
> From: Stephen Warren <swarren@nvidia.com>
> 
> Silence the following:
> net/wireless/nl80211.c: In function '__cfg80211_wdev_from_attrs.clone.119':
> net/wireless/nl80211.c:57:6: warning: 'wdev_id' may be used uninitialized in this function
> 
> ... by always initializing wdev_id to zero. I assume that wiphy_idx and
> ifidx are set to -1 for similar reasons, so this change simply propagates
> the same workaround.
> 
> In practice, this warning is false, since wdev_id is both set and used
> under the condition if (have_wdev_id). However, at least my compiler
> can't be coerced into realizing this; almost any code between the if
> blocks that set and use the variable causes this warning.

I don't see this warning? What compiler are you using?

johannes
