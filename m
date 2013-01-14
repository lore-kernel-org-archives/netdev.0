From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] drivers/net: Clean up orphaned probes in
 Space.c
Date: Mon, 14 Jan 2013 13:34:53 -0500 (EST)
Message-ID: <20130114.133453.1392976995470741961.davem@davemloft.net>
References: <1358139305-17737-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59877 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756958Ab3ANSey (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2013 13:34:54 -0500
In-Reply-To: <1358139305-17737-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Sun, 13 Jan 2013 23:55:05 -0500

> The removal of the 8390 EISA drivers actually comprises the
> complete content of the EISA probe block, so we can now remove
> that block, and its hook into the unified probe.  Note that
> the deleted comment mentions PCI probes, but they long since
> moved elsewhere, so no PCI probes are touched here.
> 
> We get rid of the orphaned EISA probe prototypes, and a couple
> of left over MCA probe prototypes at the same time.
> 
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

Applied.
