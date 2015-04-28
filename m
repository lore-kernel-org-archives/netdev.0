From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2x: really disable TPA if 'disable_tpa' option
 is set
Date: Mon, 27 Apr 2015 23:14:21 -0400 (EDT)
Message-ID: <20150427.231421.1640743940845631891.davem@davemloft.net>
References: <1430148038-25695-1-git-send-email-mschmidt@redhat.com>
	<20150427.134323.156569796484222010.davem@davemloft.net>
	<B5657A6538887040AD3A81F1008BEC63D2041C@AVMB1.qlogic.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mschmidt@redhat.com, netdev@vger.kernel.org,
	Dmitry.Kravkov@qlogic.com, Ariel.Elior@qlogic.com
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60593 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932259AbbD1DOX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2015 23:14:23 -0400
In-Reply-To: <B5657A6538887040AD3A81F1008BEC63D2041C@AVMB1.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Mon, 27 Apr 2015 18:15:44 +0000

>>> bnx2x's 'disable_tpa=1' module option is not respected properly and TPA
>>> (transparent packet aggregation) remains enabled. Even though the
>>> module option causes LRO to be disabled, TPA is enabled in GRO mode.
>>>
>>> Additionally, disabling GRO via ethtool then has no effect. One can
>>> still observe tpa_* statistics increase and large packets being received
>>> in tcpdump.
>>>
>>> The bug was an unintended consequence of commit aebf6244cd39 "bnx2x: Be
>>> more forgiving toward SW GRO".
>>>
>>> Fix it by following the bp->disable_tpa flag when initializing fp's.
>>>
>>> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
>>
>>Applied, thanks.
> 
> Michal - thanks, but Dave -is it possible you gave us only 2.5 hours to
> review this one?

You'll need to send me a revert or changes relative to this one as
the commit is not only permanent when it reaches my tree, it's also
made it's way into Linus's tree now as well.
