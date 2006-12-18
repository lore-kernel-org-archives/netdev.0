From: Zhu Yi <yi.zhu@intel.com>
Subject: RE: [PATCH 5/6] d80211: add IEEE 802.11e Direct Link Setup (DLS)
	support
Date: Mon, 18 Dec 2006 17:19:23 +0800
Message-ID: <1166433563.10342.45.camel@debian.sh.intel.com>
References: <C86180A8C204554D8A3323D8F6B0A29F01A1A8B8@dhost002-46.dex002.intermedia.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:4916 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753611AbWLRJWH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Dec 2006 04:22:07 -0500
To: Simon Barber <simon@devicescape.com>
In-Reply-To: <C86180A8C204554D8A3323D8F6B0A29F01A1A8B8@dhost002-46.dex002.intermedia.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-12-14 at 21:48 -0800, Simon Barber wrote:
> Again - this DLS management frame processing code should not be in the
> kernel - it should be in wpa_supplicant.
> 
> Only the frame processing code should be in the kernel.

OK. The DLS management process code needs the decision making from the
user. I agree to move them to userspace. But the frame sending code and
DLS data structure should be in the kernel.

Thanks,
-yi
