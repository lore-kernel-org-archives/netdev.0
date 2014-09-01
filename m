From: Shakil A Khan <shakilk1729@gmail.com>
Subject: Re: [PATCH 2/2] nl80211.c: Fixed the wdev_id being used uninitialized.
Date: Mon, 1 Sep 2014 08:33:10 -0400
Message-ID: <201409010833.10647.shakilk1729@gmail.com>
References: <1409572467-50908-1-git-send-email-shakilk1729@gmail.com> <1409573258.2703.0.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, davem@davemloft.net, linville@tuxdriver.com
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1409573258.2703.0.camel@jlt4.sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 01 September 2014 08:07:38 Johannes Berg wrote:
> > +	u64 wdev_id = 0;
> 
> it's not used uninitialized, NACK.
> 
> johannes
> 

wdev_id can be used uninitialized if  have_wdev_id turns to be false, which may happen if the entry for NL80211_ATTR_WDEV is removed in future. Who knows.
