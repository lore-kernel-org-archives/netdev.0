From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tipc: remove inline instances from C source
 files.
Date: Tue, 24 Apr 2012 00:41:34 -0400 (EDT)
Message-ID: <20120424.004134.2151175149741556237.davem@davemloft.net>
References: <20120420.204519.1199177754002742782.davem@davemloft.net>
	<1335192553-19054-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35379 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751064Ab2DXElg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2012 00:41:36 -0400
In-Reply-To: <1335192553-19054-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Mon, 23 Apr 2012 10:49:13 -0400

> Untie gcc's hands and let it do what it wants within the
> individual source files.  There are two files, node.c and
> port.c -- only the latter effectively changes (gcc-4.5.2).
> Objdump shows gcc deciding to not inline port_peernode().
> 
> Suggested-by: David S. Miller <davem@davemloft.net>
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

Applied, thanks Paul.
