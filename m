From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: Do not trigger BUG_ON when deleting assoc
 without primary path
Date: Fri, 18 Oct 2013 16:38:43 -0400 (EDT)
Message-ID: <20131018.163843.394049429297788865.davem@davemloft.net>
References: <1382031042-27339-1-git-send-email-vyasevich@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	Mark.Thomas@metaswitch.com, dborkman@redhat.com,
	nhorman@tuxdriver.com
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58263 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751013Ab3JRUip (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 16:38:45 -0400
In-Reply-To: <1382031042-27339-1-git-send-email-vyasevich@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevich@gmail.com>
Date: Thu, 17 Oct 2013 13:30:42 -0400

> It is possible to enter sctp_cmd_delete_tcb() without having a
> primary path.  The situations this most often happens in is
> when duplication cookie processing is triggered.  In this
> case, we are deleting a temporarily created association that
> is not fully populated.   Additially, at the time we
> are deleting the offending association, it is really too
> late to issue a BUG!

Vlad, it looks like you and Daniel are working on an alternative
scheme to handle this issue.  So I just toss this patch for now?
