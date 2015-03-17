From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 3/3] Validate all netlink attributes and
 return error if any of the validation fails.
Date: Tue, 17 Mar 2015 00:25:29 -0400 (EDT)
Message-ID: <20150317.002529.1577342244281556547.davem@davemloft.net>
References: <cover.1426509272.git.siva.mannem.lnx@gmail.com>
	<cover.1426509272.git.siva.mannem.lnx@gmail.com>
	<5269ddae1a0a164a488703654c9bb6e24845c637.1426509272.git.siva.mannem.lnx@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sfeldma@gmail.com
To: siva.mannem.lnx@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42611 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751386AbbCQEZb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 00:25:31 -0400
In-Reply-To: <5269ddae1a0a164a488703654c9bb6e24845c637.1426509272.git.siva.mannem.lnx@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Also, this should be the first change in your patch series.

Your current first patch just adds more bogus range checking to the
helper functions, which this patch makes %100 unnecessary.
