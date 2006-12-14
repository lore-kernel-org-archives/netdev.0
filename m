From: David Miller <davem@davemloft.net>
Subject: Re: [AX.25 1/7] Mark all kmalloc users __must_check
Date: Thu, 14 Dec 2006 15:52:36 -0800 (PST)
Message-ID: <20061214.155236.101870258.davem@davemloft.net>
References: <11661361331883-git-send-email-ralf@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-hams@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59868
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752008AbWLNXwh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Dec 2006 18:52:37 -0500
To: ralf@linux-mips.org
In-Reply-To: <11661361331883-git-send-email-ralf@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ralf Baechle <ralf@linux-mips.org>
Date: Thu, 14 Dec 2006 23:42:07 +0100

> The recent fix 0506d4068bad834aab1141b5dc5e748eb175c6b3 made obvious that
> error values were not being propagated through the AX.25 stack.  To help
> with that this patch marks all kmalloc users in the AX.25, NETROM and
> ROSE stacks as __must_check.
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

Applied.
