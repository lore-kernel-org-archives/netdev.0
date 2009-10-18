From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] genetlink: Optimize and one bug fix in
 genl_generate_id()
Date: Sat, 17 Oct 2009 23:58:10 -0700 (PDT)
Message-ID: <20091017.235810.19115879.davem@davemloft.net>
References: <20091015055453.30128.12160.sendpatchset@localhost.localdomain>
	<20091015055507.30128.60763.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: krkumar2@in.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50047
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752293AbZJRG5s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Oct 2009 02:57:48 -0400
In-Reply-To: <20091015055507.30128.60763.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>
Date: Thu, 15 Oct 2009 11:25:07 +0530

> From: Krishna Kumar <krkumar2@in.ibm.com>
> 
> 1. GENL_MIN_ID is a valid id -> no need to start at
>    GENL_MIN_ID + 1.
> 2. Avoid going through the ids two times: If we start at
>    GENL_MIN_ID+1 (*or bigger*) and all ids are over!, the
>    code iterates through the list twice (*or lesser*).
> 3. Simplify code - no need to start at idx=0 which gets
>    reset to GENL_MIN_ID.
> 
> Patch on net-next-2.6. Reboot test shows that first id
> passed to genl_register_family was 16, next two were
> GENL_ID_GENERATE and genl_generate_id returned 17 & 18
> (user level testing of same code shows expected values
> across entire range of MIN/MAX).
> 
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>

Applied, thanks.
