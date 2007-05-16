From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [PATCH] e1000: Fix msi enable leak on error, don't print error
 message,	cleanup
Date: Wed, 16 May 2007 12:05:05 -0700
Message-ID: <464B55E1.8040501@zytor.com>
References: <20070516083120.23311.3272.stgit@localhost.localdomain> <464B2426.9060502@garzik.org> <464B504B.5090007@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, Auke Kok <auke-jan.h.kok@intel.com>,
	netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([192.83.249.54]:60400 "EHLO
	terminus.zytor.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758123AbXEPTFQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2007 15:05:16 -0400
In-Reply-To: <464B504B.5090007@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rick Jones wrote:
> Some more of my paranoid questions :)
> 
> So, if a driver tries to enable MSI and that is unsuccessful (I'll try
> to avoid using the possibly loaded term "fails") shouldn't that show-up
> _somewhere_?

It already does -- in /proc/interrupts.

> Just how "normal" is an attempt to enable MSI not succeding
> going to remain over time and aren't there times when it does indeed
> mean that someone should be looking into it?

If we ever want a message, that should go in the general code and not in
each driver.

	-hpa
