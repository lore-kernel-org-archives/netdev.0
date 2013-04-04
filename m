From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] r8169: fix auto speed down issue
Date: Thu, 04 Apr 2013 17:46:33 -0400 (EDT)
Message-ID: <20130404.174633.55409356599454602.davem@davemloft.net>
References: <1364541062-9024-1-git-send-email-hayeswang@realtek.com>
	<1364785324-1604-1-git-send-email-hayeswang@realtek.com>
	<20130402213736.GA15328@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hayeswang@realtek.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, bowgotsai@google.com
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50691 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761901Ab3DDVqg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Apr 2013 17:46:36 -0400
In-Reply-To: <20130402213736.GA15328@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Tue, 2 Apr 2013 23:37:36 +0200

> Hayes Wang <hayeswang@realtek.com> :
>> It would cause no link after suspending or shutdowning when the
>> nic changes the speed to 10M and connects to a link partner which
>> forces the speed to 100M.
>> 
>> Check the link partner ability to determine which speed to set.
>> 
>> Signed-off-by: Hayes Wang <hayeswang@realtek.com>
> 
> Acked-by: Francois Romieu <romieu@fr.zoreil.com>

Applied.

>> +static void rtl_speed_down(struct rtl8169_private *tp)
>> +{
>> +	u32	adv;
>> +	int	lpa;
>            ^^^^^
> Please use a single, true space (no tabs) next time.

I fixed this up when I applied this patch, thanks.
