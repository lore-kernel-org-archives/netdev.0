From: David Miller <davem@davemloft.net>
Subject: Re: Seeing new kernel unaligned access messages in linux-next on
 ia64
Date: Wed, 24 Mar 2010 20:32:49 -0700 (PDT)
Message-ID: <20100324.203249.97351120.davem@davemloft.net>
References: <alpine.LSU.2.01.1003242059230.4028@obet.zrqbmnf.qr>
	<m2vdcl5ocj.fsf@igel.home>
	<alpine.LSU.2.01.1003250014400.16715@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: schwab@linux-m68k.org, tony.luck@intel.com, netdev@vger.kernel.org
To: jengelh@medozas.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37495
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751970Ab0CYDcZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 23:32:25 -0400
In-Reply-To: <alpine.LSU.2.01.1003250014400.16715@obet.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Engelhardt <jengelh@medozas.de>
Date: Thu, 25 Mar 2010 00:17:01 +0100 (CET)

> No more unaligned messages - but is this an acceptable solution?

We already rely on this elsewhere, particularly in the
xfrm_user code.
