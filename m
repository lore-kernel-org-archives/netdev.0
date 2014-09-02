From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] bnx2x: Configure device endianity on driver
 load and reset endianity on removal.
Date: Tue, 02 Sep 2014 13:55:26 -0700 (PDT)
Message-ID: <20140902.135526.520876149203677318.davem@davemloft.net>
References: <1409646685-28320-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Elior@qlogic.com,
	Yuval.Mintz@qlogic.com
To: manish.chopra@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58534 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754164AbaIBUz0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 16:55:26 -0400
In-Reply-To: <1409646685-28320-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@qlogic.com>
Date: Tue, 2 Sep 2014 04:31:25 -0400

> Some hosts can be both little and big endian.
> In certain scenarios a big endian kernel can kexec a little endian kernel.
> 
> This patch fixes this case from both ends:
> 1) Return endianity to original values on shutdown (in case little endian kernel boots after we shutdown).
> 2) Do not rely on HW reset values when loading driver in little endian kernel
>    but configure them explicitly (in case previous kernel was big endian and did not reset the HW).
> 
> Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
> Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>

Applied.
