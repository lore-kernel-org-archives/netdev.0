From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 2/2] nl80211.c: Fixed the wdev_id being used
 uninitialized.
Date: Mon, 01 Sep 2014 14:07:38 +0200
Message-ID: <1409573258.2703.0.camel@jlt4.sipsolutions.net>
References: <1409572467-50908-1-git-send-email-shakilk1729@gmail.com>
	 (sfid-20140901_135440_786712_355C815A)
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, davem@davemloft.net, linville@tuxdriver.com
To: Shakil A Khan <shakilk1729@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1409572467-50908-1-git-send-email-shakilk1729@gmail.com> (sfid-20140901_135440_786712_355C815A)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> +	u64 wdev_id = 0;

it's not used uninitialized, NACK.

johannes
