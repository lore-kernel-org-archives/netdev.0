From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] qeth: postpone freeing of qdio memory
Date: Tue, 25 Feb 2014 18:29:19 -0500 (EST)
Message-ID: <20140225.182919.45823286071609781.davem@davemloft.net>
References: <20140224121206.GA39222@tuxmaker.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: blaschka@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58543 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751164AbaBYX3U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Feb 2014 18:29:20 -0500
In-Reply-To: <20140224121206.GA39222@tuxmaker.boeblingen.de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Date: Mon, 24 Feb 2014 13:12:06 +0100

> From: Ursula Braun <ursula.braun@de.ibm.com>
> 
> To guarantee that a qdio ccw_device no longer touches the
> qdio memory shared with Linux, the qdio ccw_device should
> be offline when freeing the qdio memory. Thus this patch
> postpones freeing of qdio memory.
> 
> Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
> Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
> Reviewed-by: Sebastian Ott <sebott@linux.vnet.ibm.com>

Applied, thanks Frank.
