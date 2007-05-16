From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] e1000: Fix msi enable leak on error, don't print error
 message,	cleanup
Date: Wed, 16 May 2007 15:09:41 -0400
Message-ID: <464B56F5.1020008@garzik.org>
References: <20070516083120.23311.3272.stgit@localhost.localdomain> <464B2426.9060502@garzik.org> <464B504B.5090007@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Auke Kok <auke-jan.h.kok@intel.com>, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net, hpa@zytor.com
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59587 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757907AbXEPTJr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 May 2007 15:09:47 -0400
In-Reply-To: <464B504B.5090007@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rick Jones wrote:
> So, if a driver tries to enable MSI and that is unsuccessful (I'll try 
> to avoid using the possibly loaded term "fails") shouldn't that show-up 
> _somewhere_? Just how "normal" is an attempt to enable MSI not succeding 
> going to remain over time and aren't there times when it does indeed 
> mean that someone should be looking into it?


If there is an MSI problem, it is the job of the PCI core to complain.

	Jeff


