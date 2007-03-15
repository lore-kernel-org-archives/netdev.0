From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6] IrDA: Updates
Date: Thu, 15 Mar 2007 03:00:54 -0700 (PDT)
Message-ID: <20070315.030054.78719597.davem@davemloft.net>
References: <20070314192236.GB3397@sortiz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, irda-users@lists.sourceforge.net
To: samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33556
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750968AbXCOKAz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Mar 2007 06:00:55 -0400
In-Reply-To: <20070314192236.GB3397@sortiz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Samuel Ortiz <samuel@sortiz.org>
Date: Wed, 14 Mar 2007 21:22:36 +0200

> Some IrDA updates:
> 
> - IrNET identation and bug fix. (patches 1 and 2)
> - IrLAP raw mode initial implementation. (patch 3)
> - stir4200 and irda-usb fixes. (patches 4 and 5)
> - hashbin lockdep fixes. (patch 6)

Indentation and coding-style cleanups are not appropriate for 2.6.21,
so I need to ask you which of these changes you need to get into
2.6.21 and which can go into the non-bug-fix 2.6.22 bound tree?

When you submit a mish-mash of cleanups and real bug fixes,
it makes life extremely difficult for me, that's why I totally
abandoned even looking at this today until right before going
to sleep.

Please properly segregate things in the future and make sure that you
submit bug fixes against net-2.6 and features against the net-2.6.22
tree.

Thank you.
