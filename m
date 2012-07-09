From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless 2012-07-06
Date: Mon, 09 Jul 2012 00:31:55 -0700 (PDT)
Message-ID: <20120709.003155.284089706826738623.davem@davemloft.net>
References: <20120706192034.GA1879@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120706192034.GA1879@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Fri, 6 Jul 2012 15:20:35 -0400

> Please let me know if there are problems!

This indentation is not correct:

commit 01f9cb073c827c60c43f769763b49a2026f1a897
Author: Thomas Huehn <thomas@net.t-labs.tu-berlin.de>
Date:   Thu Jun 28 14:39:51 2012 -0700

    mwl8k: fix possible race condition in info->control.sta use
 ...
+			sta = ieee80211_find_sta_by_ifaddr(hw, wh->addr1,
+								wh->addr2);
