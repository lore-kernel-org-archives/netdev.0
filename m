From: Jiri Slaby <jirislaby@gmail.com>
Subject: 2.6.23-rc4-mm1: e1000e napi lockup
Date: Fri, 07 Sep 2007 09:19:30 +0200
Message-ID: <46E0FB82.2040000@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	Auke Kok <auke-jan.h.kok@intel.com>,
	"David S. Miller" <davem@davemloft.net>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:46736 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964894AbXIGHTj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Sep 2007 03:19:39 -0400
Received: by ug-out-1314.google.com with SMTP id z38so249932ugc
        for <netdev@vger.kernel.org>; Fri, 07 Sep 2007 00:19:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I found a regression in 2.6.23-rc4-mm1 (since -rc3-mm1) in e1000e driver.
napi_disable(&adapter->napi) in e1000_probe freezes the kernel on boot.

regards,
-- 
Jiri Slaby (jirislaby@gmail.com)
Faculty of Informatics, Masaryk University
