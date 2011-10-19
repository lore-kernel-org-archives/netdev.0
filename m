From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-2.6] tg3: negate USE_PHYLIB flag check
Date: Wed, 19 Oct 2011 00:00:05 -0400 (EDT)
Message-ID: <20111019.000005.1573013340632702918.davem@davemloft.net>
References: <1318410041-2476-1-git-send-email-jpirko@redhat.com>
	<20111012235501.GA31550@mcarlson.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jpirko@redhat.com, netdev@vger.kernel.org, eric.dumazet@gmail.com,
	mchan@broadcom.com
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57139 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750710Ab1JSEAJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 00:00:09 -0400
In-Reply-To: <20111012235501.GA31550@mcarlson.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Wed, 12 Oct 2011 16:55:01 -0700

> On Wed, Oct 12, 2011 at 02:00:41AM -0700, Jiri Pirko wrote:
>> USE_PHYLIB flag in tg3_remove_one() is being checked incorrectly. This
>> results tg3_phy_fini->phy_disconnect is never called and when tg3 module
>> is removed.
>> 
>> In my case this resulted in panics in phy_state_machine calling function
>> phydev->adjust_link.
>> 
>> So correct this check.
>> 
>> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
> 
> Introduced by commit 63c3a66fe6c827a731dcbdee181158b295626f83, entitled
> "tg3: Convert u32 flag,flg2,flg3 uses to bitmap".
> 
> Acked-by: Matt Carlson <mcarlson@broadcom.com>

Applied and queued up for -stable, thanks!
