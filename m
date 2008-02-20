From: David Miller <davem@davemloft.net>
Subject: Re: TG3 network data corruption regression 2.6.24/2.6.23.4
Date: Wed, 20 Feb 2008 15:08:50 -0800 (PST)
Message-ID: <20080220.150850.56732755.davem@davemloft.net>
References: <47BB54C2.6090501@cybernetics.com>
	<20080220013824.GA5416@localdomain>
	<47BCB1E9.8020102@cybernetics.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mcarlson@broadcom.com, mchan@broadcom.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	gregkh@suse.de, linux-kernel@vger.kernel.org
To: tonyb@cybernetics.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37571
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753798AbYBTXIN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 18:08:13 -0500
In-Reply-To: <47BCB1E9.8020102@cybernetics.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tony Battersby <tonyb@cybernetics.com>
Date: Wed, 20 Feb 2008 18:04:09 -0500

> The following patch fixes the problem for me.  Do we want to accept this
> patch and call it a day or continue investigating the source of the problem?
> 
> Patch applies to 2.6.24.2, but doesn't apply to 2.6.25-rc.  If everyone
> agrees that this is the right solution, I will resubmit with a proper
> subject line and description.

A chipset bug, if it even exists, should be worked around in the
driver for that hardware.  We shouldn't make every other piece
of hardware in the world suffer too.

