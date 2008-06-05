From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] ipv6 addrconf: Ignore requests to set NODAD flag when
 changing addresses
Date: Thu, 05 Jun 2008 23:32:56 +0900 (JST)
Message-ID: <20080605.233256.53155823.yoshfuji@linux-ipv6.org>
References: <20080604234751.GH20815@postel.suug.ch>
	<20080605.115314.80065467.yoshfuji@linux-ipv6.org>
	<20080605090447.GL20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, usagi-core@ml.linux-ipv6.org,
	nakam@gomagoma.org, takamiya@po.ntts.co.jp, yoshfuji@linux-ipv6.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:58154 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753808AbYFEOcV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 10:32:21 -0400
In-Reply-To: <20080605090447.GL20815@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <20080605090447.GL20815@postel.suug.ch> (at Thu, 5 Jun 2008 11:04:47 +0200), Thomas Graf <tgraf@suug.ch> says:

> * YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org> 2008-06-05 11:53
> > And well, it does not take effect so far, but 
> > DAD after link failure logic is planned in long term.
> > So current code is okay to me.
> 
> Alright, that makes sense if that code ever is written.
> 
> I'm not sure I understand your new patch though, why do you want to
> disable setting the nodad flag for new addresses nowW?

If we should really need to avoid the confusion, we have an option
to disallow modification of NODAD flag so far with the patch I've posted.
But anyway, I'm going to leave it as-is if you are okay.

--yoshfuji
