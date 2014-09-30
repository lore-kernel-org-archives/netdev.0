From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] netxen: Bug fixes.
Date: Tue, 30 Sep 2014 16:23:15 -0400 (EDT)
Message-ID: <20140930.162315.1445819984262897387.davem@davemloft.net>
References: <1412063796-25959-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, umgwanakikbuti@gmail.com,
	Dept-GELinuxNICDev@qlogic.com
To: manish.chopra@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49458 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751959AbaI3UXR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 16:23:17 -0400
In-Reply-To: <1412063796-25959-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@qlogic.com>
Date: Tue, 30 Sep 2014 03:56:34 -0400

> This series fixes some TX specific issues.
> * Move spin_lock(tx_clean_lock) in down path to fix
>   atomic sleep bug (Reported by Mike Galbraith).
> * Fix hang in interface down while running traffic.
> 
> Please consider applying this to 'net'.

Series applied, thanks.
