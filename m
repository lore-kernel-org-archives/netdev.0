From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] genetlink: remove superfluous assignment
Date: Mon, 02 Jun 2014 10:36:37 -0700 (PDT)
Message-ID: <20140602.103637.1919050358452105820.davem@davemloft.net>
References: <1401346448-17105-1-git-send-email-crquan@gmail.com>
	<1401697081-17093-1-git-send-email-crquan@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: crquan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35147 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750701AbaFBRgi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 13:36:38 -0400
In-Reply-To: <1401697081-17093-1-git-send-email-crquan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: crquan@gmail.com
Date: Mon,  2 Jun 2014 01:18:01 -0700

> the local variable ops and n_ops were just read out from family,
> and not changed, hence no need to assign back.
> 
> Validation functions should operate on const parameters and not
> change anything.
> 
> Signed-off-by: Cheng Renquan <crquan@gmail.com>

Applied, thanks Cheng.
