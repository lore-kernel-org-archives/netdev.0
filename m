From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 3/9] fs_enet: Don't share the interrupt.
Date: Sat, 29 Sep 2007 01:18:32 -0400
Message-ID: <46FDE028.8080501@pobox.com>
References: <20070920220118.GC28784@loki.buserror.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Scott Wood <scottwood@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:36115 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751792AbXI2FSd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Sep 2007 01:18:33 -0400
In-Reply-To: <20070920220118.GC28784@loki.buserror.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Scott Wood wrote:
> This driver can't handle an interrupt immediately after request_irq

You MUST assume that you will receive an interrupt immediately after 
request_irq().  If fs_enet cannot handle that, then that is what wants 
fixing.

Please send along a fix for this, rather than band-aiding the problem.

