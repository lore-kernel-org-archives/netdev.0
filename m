From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 0/3] qlge: Performance changes for qlge.
Date: Wed, 06 Jan 2010 20:30:53 -0800 (PST)
Message-ID: <20100106.203053.149144229.davem@davemloft.net>
References: <1262464664-14996-1-git-send-email-ron.mercer@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59116
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756412Ab0AGEaq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2010 23:30:46 -0500
In-Reply-To: <1262464664-14996-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ron Mercer <ron.mercer@qlogic.com>
Date: Sat,  2 Jan 2010 12:37:41 -0800

> 
> Currently qlge splits headers into a separate buffer so they can
> be re-aligned on a 2-byte boundary.  This is done to avoid
> exceptions thrown on certain platforms when headers are processed.
> To avoid the overhead of re-aligning headers, we turn on the split 
> header/realign configuration only when the platform requires it.
> This allows usage of the gro-frags interface on platforms that do
> not require 32 bit aligned headers.

All applied to net-next-2.6, thanks Ron.
