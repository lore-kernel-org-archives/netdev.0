From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 3/4] bonding: Fix work rearming
Date: Wed, 16 Jan 2008 14:36:46 +0100
Message-ID: <20080116133646.GE2307@ff.dom.local>
References: <20080115090532.GB1696@ff.dom.local> <478D77D7.60703@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Makito SHIOKAWA <mshiokawa@miraclelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:8534 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752412AbYAPNaY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2008 08:30:24 -0500
Received: by ug-out-1314.google.com with SMTP id z38so211312ugc.16
        for <netdev@vger.kernel.org>; Wed, 16 Jan 2008 05:30:22 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <478D77D7.60703@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 16, 2008 at 12:19:51PM +0900, Makito SHIOKAWA wrote:
> This patch is supposing a case that bond_mii_monitor() is invoked in 
> bond_open(), and after that, 0 is set to miimon via sysfs (see same place 
> on other monitors).
> Though message in bonding_store_miimon() says miimon value 1-INT_MAX 
> rejected, but it looks like 0 can be accepted and monitor must be stopped 
> in that case.

But, since during this change from sysfs cancel_delayed_work_sync()
could be probably used, and it's rather efficient with killing
rearming works, it seems this check could be unnecessary yet.

Jarek P.
