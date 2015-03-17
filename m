From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 3/3] Validate all netlink attributes and
 return error if any of the validation fails.
Date: Tue, 17 Mar 2015 00:24:27 -0400 (EDT)
Message-ID: <20150317.002427.1841301696338614194.davem@davemloft.net>
References: <cover.1426509272.git.siva.mannem.lnx@gmail.com>
	<cover.1426509272.git.siva.mannem.lnx@gmail.com>
	<5269ddae1a0a164a488703654c9bb6e24845c637.1426509272.git.siva.mannem.lnx@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sfeldma@gmail.com
To: siva.mannem.lnx@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42605 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751191AbbCQEYb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 00:24:31 -0400
In-Reply-To: <5269ddae1a0a164a488703654c9bb6e24845c637.1426509272.git.siva.mannem.lnx@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Siva Mannem <siva.mannem.lnx@gmail.com>
Date: Tue, 17 Mar 2015 04:32:44 +0530

> This patch validates all netlink attributes and return error if any of the
> validation fails.
> 
> Signed-off-by: Siva Mannem <siva.mannem.lnx@gmail.com>
> Suggested-by: David Miller <davem@davemloft.net>

You have to remove the range checking code from all the other
functions too.

Then no errors can be returned by them at all actually and that's an
really nice cleanup.

Please don't make microscopic narrow changes like this, think about
the higher level implications and the things that are no longer
necessary as a result.

Thanks.
