From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] Trivial fixes for cxgb4
Date: Tue, 12 Aug 2014 14:20:23 -0700 (PDT)
Message-ID: <20140812.142023.190072605686378631.davem@davemloft.net>
References: <1407821953-8711-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com,
	kumaras@chelsio.com, anish@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39137 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752829AbaHLVUZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2014 17:20:25 -0400
In-Reply-To: <1407821953-8711-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Tue, 12 Aug 2014 11:09:07 +0530

> This patch series adds support to fix T5 adapter accessing T4
> adapter registers, issue mbox command on correct mbox for physical
> function, avoid dumping write only registers, use correct length for
> adapter part number and support to detect and display firmware
> reported errors.
> 
> The patches series is created against 'net-next' tree.
> And includes patches on cxgb4 driver.
> 
> We have included all the maintainers of respective drivers. Kindly review the
> change and let us know in case of any review comments.

If these are bug fixes why are you not targetting the 'net' tree?

Secondly, your commit messages are too terse.  For example, in patch
#1 you just say "Fix for handling 1Gb/s SFP+ Transceiver Modules"
which doesn't tell anyone reading the change what the problem was.

What needed to be fixed?  What wasn't being done correctly and how
is it being fixed?

You can't just say "Fix xxx", that doesn't tell the reader anything.
You can say "Fix xxx" in the commit message header line, but then
you have to go into detail about the issue in the commit message
body.
