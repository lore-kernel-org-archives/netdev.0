From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: Seeing new kernel unaligned access messages in linux-next on
 ia64
Date: Wed, 24 Mar 2010 16:19:38 -0700
Message-ID: <987664A83D2D224EAE907B061CE93D53B30F00F1@orsmsx505.amr.corp.intel.com>
References: <12c511ca1003181112t6098eeafm30e384e755a42185@mail.gmail.com>
 <alpine.LSU.2.01.1003192310450.10055@obet.zrqbmnf.qr>
 <20100324.102759.107122703.davem@davemloft.net>
 <alpine.LSU.2.01.1003242059230.4028@obet.zrqbmnf.qr>
 <m2vdcl5ocj.fsf@igel.home>
 <alpine.LSU.2.01.1003250014400.16715@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jan Engelhardt <jengelh@medozas.de>,
	Andreas Schwab <schwab@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:34199 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751283Ab0CXXTj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 19:19:39 -0400
In-Reply-To: <alpine.LSU.2.01.1003250014400.16715@obet.zrqbmnf.qr>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> No more unaligned messages - but is this an acceptable solution?

There are a bunch of macros in include/linux/unaligned/*.h to
handle this sort of thing.

-Tony
