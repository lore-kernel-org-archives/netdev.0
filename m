From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: is the commit 571dcfde2371 (net-next) a proper fix?
Date: Mon, 08 Dec 2014 12:23:20 +0200
Message-ID: <1418034200.17201.45.camel@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Huacai Chen <chenhc@lemote.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:2180 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752144AbaLHKXV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Dec 2014 05:23:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

It seems for me that commit 571dcfde2371 (stmmac: platform: fix default
values of the filter bins setting) is redundant (moreover, it could be a
cause of crash in some cases when there is no platform data defined in
case of CONFIG_OF).

In case of no OF the platform data should be provided by platform code
where the defaults are set. What did I miss?


-- 
Andy Shevchenko <andriy.shevchenko@intel.com>
Intel Finland Oy
