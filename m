From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] e1000: Fix msi enable leak on error, don't print error
 message, cleanup
Date: Wed, 16 May 2007 12:27:47 -0700 (PDT)
Message-ID: <20070516.122747.74561154.davem@davemloft.net>
References: <20070516083120.23311.3272.stgit@localhost.localdomain>
	<464B2426.9060502@garzik.org>
	<464B504B.5090007@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, auke-jan.h.kok@intel.com, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net, hpa@zytor.com
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50285
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759454AbXEPT1l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2007 15:27:41 -0400
In-Reply-To: <464B504B.5090007@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rick Jones <rick.jones2@hp.com>
Date: Wed, 16 May 2007 11:41:15 -0700

> Some more of my paranoid questions :)
> 
> So, if a driver tries to enable MSI and that is unsuccessful (I'll try to avoid 
> using the possibly loaded term "fails") shouldn't that show-up _somewhere_? 
> Just how "normal" is an attempt to enable MSI not succeding going to remain over 
> time and aren't there times when it does indeed mean that someone should be 
> looking into it?

We have whole platforms where pci_enable_msi() is going to fail on
every call, it doesn't help to mention this to be honest.
