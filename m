From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] rhashtable-test: Fix 64bit division
Date: Tue, 05 May 2015 19:31:04 -0400 (EDT)
Message-ID: <20150505.193104.1561516010227429029.davem@davemloft.net>
References: <ce3dfbe753021ac49b34560aabe874d6f8fdc63e.1430785419.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57950 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753924AbbEEXbF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 19:31:05 -0400
In-Reply-To: <ce3dfbe753021ac49b34560aabe874d6f8fdc63e.1430785419.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Tue,  5 May 2015 02:27:02 +0200

> A 64bit division went in unnoticed. Use do_div() to accomodate
> non 64bit architectures.
> 
> Reported-by: kbuild test robot
> Fixes: 1aa661f5c3df ("rhashtable-test: Measure time to insert, remove & traverse entries")
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied.
