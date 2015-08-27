From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v4] sctp: asconf's process should verify address
 parameter is in the beginning
Date: Thu, 27 Aug 2015 14:00:00 -0700 (PDT)
Message-ID: <20150827.140000.2029372676821851500.davem@davemloft.net>
References: <842bb5735d0ea0e632695f49dc85021faa176784.1440663994.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mleitner@redhat.com, vyasevic@redhat.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46897 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751231AbbH0VAB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 17:00:01 -0400
In-Reply-To: <842bb5735d0ea0e632695f49dc85021faa176784.1440663994.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Thu, 27 Aug 2015 16:26:34 +0800

> in sctp_process_asconf(), we get address parameter from the beginning of
> the addip params. but we never check if it's really there. if the addr
> param is not there, it still can pass sctp_verify_asconf(), then to be
> handled by sctp_process_asconf(), it will not be safe.
> 
> so add a code in sctp_verify_asconf() to check the address parameter is in
> the beginning, or return false to send abort.
> 
> note that this can also detect multiple address parameters, and reject it.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>

Applied, thanks.
