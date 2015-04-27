From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2x: really disable TPA if 'disable_tpa' option
 is set
Date: Mon, 27 Apr 2015 13:43:23 -0400 (EDT)
Message-ID: <20150427.134323.156569796484222010.davem@davemloft.net>
References: <1430148038-25695-1-git-send-email-mschmidt@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dmitry.Kravkov@qlogic.com,
	Yuval.Mintz@qlogic.com, Ariel.Elior@qlogic.com
To: mschmidt@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56305 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932208AbbD0RnZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2015 13:43:25 -0400
In-Reply-To: <1430148038-25695-1-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Schmidt <mschmidt@redhat.com>
Date: Mon, 27 Apr 2015 17:20:38 +0200

> bnx2x's 'disable_tpa=1' module option is not respected properly and TPA
> (transparent packet aggregation) remains enabled. Even though the
> module option causes LRO to be disabled, TPA is enabled in GRO mode.
> 
> Additionally, disabling GRO via ethtool then has no effect. One can
> still observe tpa_* statistics increase and large packets being received
> in tcpdump.
> 
> The bug was an unintended consequence of commit aebf6244cd39 "bnx2x: Be
> more forgiving toward SW GRO".
> 
> Fix it by following the bp->disable_tpa flag when initializing fp's.
> 
> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>

Applied, thanks.
