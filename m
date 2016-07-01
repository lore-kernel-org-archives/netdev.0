From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] qlcnic: add wmb() call in transmit data path.
Date: Fri, 01 Jul 2016 05:00:56 -0400 (EDT)
Message-ID: <20160701.050056.1884764208417440840.davem@davemloft.net>
References: <1467237094-23088-1-git-send-email-sony.chacko@qlogic.com>
	<1467237094-23088-2-git-send-email-sony.chacko@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com
To: sony.chacko@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37103 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752526AbcGAJBZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 05:01:25 -0400
In-Reply-To: <1467237094-23088-2-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>
Date: Wed, 29 Jun 2016 17:51:34 -0400

> Call wmb() to ensure writes are complete before
> hardware fetches updated Tx descriptors.
> 
> Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>

Applied, thanks.
