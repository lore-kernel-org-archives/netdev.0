From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 5/7] ieee80211: export symbol ieee80211_api_version
Date: Mon, 21 Aug 2006 10:51:20 +0100
Message-ID: <20060821095120.GA2770@infradead.org>
References: <20060821033340.GA4802@mail.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:44706 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S1751811AbWHUJvY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Aug 2006 05:51:24 -0400
To: Zhu Yi <yi.zhu@intel.com>
Content-Disposition: inline
In-Reply-To: <20060821033340.GA4802@mail.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 21, 2006 at 11:33:40AM +0800, Zhu Yi wrote:
> Export this symbol so that wireless drivers can check the running IEEE80211
> API version dynamically.

NACK (Or should I say no f***ing way :)).  We don't export runtime subsystem
versions, especially as they are totally useless already.  Please submit
a patch to remove the already meaningless net/ieee80211/ versioning instead.
