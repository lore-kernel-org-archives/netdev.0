From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169: fix driver shutdown WoL regression.
Date: Wed, 19 Oct 2011 17:08:08 -0400 (EDT)
Message-ID: <20111019.170808.1758618999682989189.davem@davemloft.net>
References: <20111014105745.GA11204@electric-eye.fr.zoreil.com>
	<20111014141221.5736721ec0dc65de0537ac48@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org, hayeswang@realtek.com
To: ballarin.marc@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39500 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753559Ab1JSVJY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 17:09:24 -0400
In-Reply-To: <20111014141221.5736721ec0dc65de0537ac48@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marc Ballarin <ballarin.marc@gmx.de>
Date: Fri, 14 Oct 2011 14:12:21 +0200

> On Fri, 14 Oct 2011 12:57:45 +0200
> Francois Romieu <romieu@fr.zoreil.com> wrote:
> 
>> ...
>>   Marc, can you add your Tested-by: to this patch ? It avoids the extra
>>   phy writes which were included in the previous revision of the patch.
>>   They did not happen before the regression so there is no reason to
>>   sneak them in -release. Works ok with RTL_GIGA_MAC_VER_34.
> 
> Works fine on RTL_GIGA_MAC_VER_33 as well.
> 
> Tested-by: Marc Ballarin <ballarin.marc@gmx.de>

I'll apply this, thanks everyone.
