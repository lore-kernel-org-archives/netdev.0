From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tg3: Avoid panic from reserved statblk field access
Date: Wed, 25 Apr 2012 14:42:15 -0400 (EDT)
Message-ID: <20120425.144215.1558381345718916443.davem@davemloft.net>
References: <1335310621-7795-1-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52930 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757300Ab2DYSmS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2012 14:42:18 -0400
In-Reply-To: <1335310621-7795-1-git-send-email-mcarlson@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Tue, 24 Apr 2012 16:37:01 -0700

> When RSS is enabled, interrupt vector 0 does not receive any rx traffic.
> The rx producer index fields for vector 0's status block should be
> considered reserved in this case.  This patch changes the code to
> respect these reserved fields, which avoids a kernel panic when these
> fields take on non-zero values.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied and queued up for -stable, thanks.
