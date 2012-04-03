From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169: enable napi on resume.
Date: Tue, 03 Apr 2012 19:09:14 -0400 (EDT)
Message-ID: <20120403.190914.538968019741351033.davem@davemloft.net>
References: <1333484951-5432-1-git-send-email-artem.savkov@gmail.com>
	<20120403230317.GA6165@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: artem.savkov@gmail.com, nic_swsd@realtek.com,
	netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39414 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753693Ab2DCXKY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 19:10:24 -0400
In-Reply-To: <20120403230317.GA6165@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Wed, 4 Apr 2012 01:03:17 +0200

> Artem Savkov <artem.savkov@gmail.com> :
>> NAPI is disabled during suspend and needs to be enabled on resume. Without
>> this the driver locks up during resume in rtl_reset_work() trying to disable
>> NAPI again.
>> 
>> Signed-off-by: Artem Savkov <artem.savkov@gmail.com>
> 
> :o(
> 
> It fixes runtime_{suspend / resume} as well.
> 
> Acked-by: Francois Romieu <romieu@fr.zoreil.com>

Applied and queued up for -stable, thanks.
