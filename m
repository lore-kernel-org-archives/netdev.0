From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 2/2] nl80211.c: Fixed the wdev_id being used
 uninitialized.
Date: Mon, 01 Sep 2014 14:42:22 +0200
Message-ID: <1409575342.2703.4.camel@jlt4.sipsolutions.net>
References: <1409572467-50908-1-git-send-email-shakilk1729@gmail.com>
	 <1409573258.2703.0.camel@jlt4.sipsolutions.net>
	 <201409010833.10647.shakilk1729@gmail.com>
	 (sfid-20140901_143315_542502_C9A8C225)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, davem@davemloft.net, linville@tuxdriver.com
To: Shakil A Khan <shakilk1729@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201409010833.10647.shakilk1729@gmail.com> (sfid-20140901_143315_542502_C9A8C225)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-09-01 at 08:33 -0400, Shakil A Khan wrote:
> On Monday 01 September 2014 08:07:38 Johannes Berg wrote:
> > > +	u64 wdev_id = 0;
> > 
> > it's not used uninitialized, NACK.
> > 
> > johannes
> > 
> 
> wdev_id can be used uninitialized if  have_wdev_id turns to be false,
> which may happen if the entry for NL80211_ATTR_WDEV is removed in
> future. Who knows.

In which case the compiler will warn about it. If you were to use a
newer compiler now, you wouldn't see the warning.

johannes
