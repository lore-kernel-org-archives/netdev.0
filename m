From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless 2013-06-03
Date: Tue, 04 Jun 2013 13:18:13 -0700 (PDT)
Message-ID: <20130604.131813.134898245916084893.davem@davemloft.net>
References: <20130603184817.GD2727@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130603184817.GD2727@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Mon, 3 Jun 2013 14:48:17 -0400

> Please let me know if there are problems!

Sorry, the broadcom brcmfmac changes need to go.

Some of those commits are cleanups, and some of them have the worst
commit log messages ever, the last one for example:

0017-brcmsmac-fix-regression-observed-in-3.10-rc1.patch

has no explanation whatsoever of what the actual problem or regression
is, what aspect of the logic in that function is causing the problem,
and no explanation why making this function always return 'false' is a
reasonable fix.

That entire series is of very low quality, and even if it was in good
shape, at least half the changes are not appropriate at all this late
in the -rc series.
