From: David Miller <davem@davemloft.net>
Subject: Re: updates to syncookies - timestamps not needed any more
 (freebsd)
Date: Thu, 11 Jul 2013 16:57:26 -0700 (PDT)
Message-ID: <20130711.165726.2168148122875413191.davem@davemloft.net>
References: <20130708160421.GA9763@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33581 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753987Ab3GKX51 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 19:57:27 -0400
In-Reply-To: <20130708160421.GA9763@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Mon, 8 Jul 2013 18:04:21 +0200

> Interesting patch by Andre Opperann of FreeBSD:
> <http://lists.freebsd.org/pipermail/freebsd-net/2013-July/035999.html>

Interesting work, but outside of the change of hash function I'm not so
sure.  The whole reason we went to the timestamp field was to eliminate
the coarse tables.

I understand that he claims that %99.99 of connections are handled by
the values he has chosen, but this is still a step backwards in my
opinion.
