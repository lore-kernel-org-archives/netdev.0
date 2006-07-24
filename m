From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH wireless-dev 2/5] orinoco: Switch to d80211.h
Date: Mon, 24 Jul 2006 05:03:55 +0100
Message-ID: <20060724040355.GA6823@infradead.org>
References: <200607232040.37823.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linville@tuxdriver.com, Jiri Benc <jbenc@suse.cz>,
	netdev@vger.kernel.org, proski@gnu.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:17900 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S1751401AbWGXEEF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jul 2006 00:04:05 -0400
To: Michael Wu <flamingice@sourmilk.net>
Content-Disposition: inline
In-Reply-To: <200607232040.37823.flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jul 23, 2006 at 08:40:20PM -0700, Michael Wu wrote:
> orinoco: Switch to d80211.h
> 
> This patch "converts" the orinoco driver to use d80211.h instead of
> ieee80211.h. It also copies the IEEE80211_DATA_LEN definition to
> d80211.h for use by the stack and drivers.

NACK for all of these patches.  The names in ieee80211.h

 a) make a whole lot more sense
 b) are used all over the kernel already

please convert the devicescape stack to reuse existing infrastrucure instead,
and that starts with things as simple as names for constants and data
structures in headers.

