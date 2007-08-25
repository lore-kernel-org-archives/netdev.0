From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [NET] sgiseeq: Fix return type of sgiseeq_remove
Date: Sat, 25 Aug 2007 00:41:10 -0400
Message-ID: <46CFB2E6.6010206@garzik.org>
References: <20070822150352.GA18889@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:42174 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750695AbXHYElM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Aug 2007 00:41:12 -0400
In-Reply-To: <20070822150352.GA18889@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ralf Baechle wrote:
> The driver remove method needs to return an int not void.  This was just
> never noticed because usually this driver is not being built as a module.
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

applied


