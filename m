From: Abhishek <guptaa80@ymail.com>
Subject: Re: Problem with passing =?utf-8?b?cHR5cGVfYmFzZQ==?= list as a function argument
Date: Mon, 19 Jul 2010 08:53:03 +0000 (UTC)
Message-ID: <loom.20100719T105146-350@post.gmane.org>
References: <loom.20100719T063120-919@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:58061 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760228Ab0GSIxQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jul 2010 04:53:16 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1Oam63-0004ya-MU
	for netdev@vger.kernel.org; Mon, 19 Jul 2010 10:53:12 +0200
Received: from ABTS-KK-Static-ILP-034.159.181.122.airtel.in ([ABTS-KK-Static-ILP-034.159.181.122.airtel.in])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 19 Jul 2010 10:53:11 +0200
Received: from guptaa80 by ABTS-KK-Static-ILP-034.159.181.122.airtel.in with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 19 Jul 2010 10:53:11 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In addition to the aforementioned information, I would like add one more thing: 
the function foo() belongs to a separate module and is not part of the dev.c 
file. Hence, dev.c also includes the function exporting line: 
EXPORT_SYMBOL(foo);


