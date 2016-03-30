From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qed: initialize return rc to avoid returning garbage
Date: Wed, 30 Mar 2016 15:48:42 -0400 (EDT)
Message-ID: <20160330.154842.1616404973583316987.davem@davemloft.net>
References: <1459270850-16177-1-git-send-email-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Yuval.Mintz@qlogic.com, Ariel.Elior@qlogic.com,
	everest-linux-l2@qlogic.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37526 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752283AbcC3Tso (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2016 15:48:44 -0400
In-Reply-To: <1459270850-16177-1-git-send-email-colin.king@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin King <colin.king@canonical.com>
Date: Tue, 29 Mar 2016 18:00:50 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> in the case where qed_slowpath_irq_req is not called, rc is not
> assigned and so qed_int_igu_enable will return a garbage value.
> Fix this by initializing rc to 0.
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied, thanks.
