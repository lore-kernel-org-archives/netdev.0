From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v5 02/11] htb: fix values in opt dump
Date: Tue, 12 Feb 2013 18:51:59 -0500 (EST)
Message-ID: <20130212.185159.2082666420632089509.davem@davemloft.net>
References: <1360663929-1023-1-git-send-email-jiri@resnulli.us>
	<1360663929-1023-3-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, jhs@mojatatu.com,
	kuznet@ms2.inr.ac.ru, j.vimal@gmail.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58762 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753642Ab3BLXwB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 18:52:01 -0500
In-Reply-To: <1360663929-1023-3-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue, 12 Feb 2013 11:12:00 +0100

> in htb_change_class() cl->buffer and cl->buffer are stored in ns.
> So in dump, convert them back to psched ticks.
> 
> Note this was introduced by:
> commit 56b765b79e9a78dc7d3f8850ba5e5567205a3ecd
>     htb: improved accuracy at high rates
> 
> Please consider this for -net/-stable.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> Acked-by: Eric Dumazet <edumazet@google.com>

Applied to 'net' and queued up for -stable, thanks.
