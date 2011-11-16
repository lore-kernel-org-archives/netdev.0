From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/1] drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h:
 remove unused macro pr_fmt()
Date: Wed, 16 Nov 2011 17:48:57 -0500 (EST)
Message-ID: <20111116.174857.2263466530525059119.davem@davemloft.net>
References: <201111152255.pAFMtTo5005370@wpaz5.hot.corp.google.com>
	<20111115.183808.2066749950387258221.davem@davemloft.net>
	<20111115155210.69249eb9.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	tomoya-linux@dsn.okisemi.com, toshiharu-linux@dsn.okisemi.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57733 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754207Ab1KPWtD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 17:49:03 -0500
In-Reply-To: <20111115155210.69249eb9.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Tue, 15 Nov 2011 15:52:10 -0800

> On Tue, 15 Nov 2011 18:38:08 -0500 (EST)
> David Miller <davem@davemloft.net> wrote:
> 
>> From: akpm@linux-foundation.org
>> Date: Tue, 15 Nov 2011 14:55:29 -0800
>> 
>> > From: Andrew Morton <akpm@linux-foundation.org>
>> > Subject: drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h: remove unused macro pr_fmt()
>> 
>> It's not unused, it just isn't properly coming before the linux/printk.h
>> include.
> 
> Oh well, I'll drop it.  Please treat the patch as a bug report instead.

Joe Perches took care of it, I just applied a proper fix from him.

Thanks.
