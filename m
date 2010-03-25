From: David Miller <davem@davemloft.net>
Subject: Re: Seeing new kernel unaligned access messages in linux-next on
 ia64
Date: Wed, 24 Mar 2010 20:32:26 -0700 (PDT)
Message-ID: <20100324.203226.150151401.davem@davemloft.net>
References: <m2vdcl5ocj.fsf@igel.home>
	<alpine.LSU.2.01.1003250014400.16715@obet.zrqbmnf.qr>
	<987664A83D2D224EAE907B061CE93D53B30F00F1@orsmsx505.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jengelh@medozas.de, schwab@linux-m68k.org, netdev@vger.kernel.org
To: tony.luck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37491
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751788Ab0CYDcG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 23:32:06 -0400
In-Reply-To: <987664A83D2D224EAE907B061CE93D53B30F00F1@orsmsx505.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 24 Mar 2010 16:19:38 -0700

>> No more unaligned messages - but is this an acceptable solution?
> 
> There are a bunch of macros in include/linux/unaligned/*.h to
> handle this sort of thing.

It's totally unnecessary here and it would be overkill to
use those interfaces one at a time on every struct member
when a proper memcpy() fro ma type-pruned void pointer
suffices.
