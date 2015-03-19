From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] bnx2x: Fix statistics locking scheme
Date: Thu, 19 Mar 2015 12:23:35 -0400 (EDT)
Message-ID: <20150319.122335.774892347141858153.davem@davemloft.net>
References: <1426688042-20315-1-git-send-email-Yuval.Mintz@qlogic.com>
	<20150318.151059.979411313448939306.davem@davemloft.net>
	<B5657A6538887040AD3A81F1008BEC63C1401F@avmb3.qlogic.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Elior@qlogic.com
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47845 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751031AbbCSQXk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 12:23:40 -0400
In-Reply-To: <B5657A6538887040AD3A81F1008BEC63C1401F@avmb3.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Thu, 19 Mar 2015 07:26:25 +0000

> Do you prefer I simply switch over into using a regular mutex?

Yes, I do, unless you can prove that it is insufficient.
