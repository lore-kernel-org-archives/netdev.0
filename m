From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] phylib: add a way to make PHY time stamps possible.
Date: Mon, 05 Jul 2010 19:03:07 -0700 (PDT)
Message-ID: <20100705.190307.260098804.davem@davemloft.net>
References: <cover.1278307573.git.richard.cochran@omicron.at>
	<f5d438863bb1132293cb6eab89fe199a739e4957.1278307573.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48217
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755877Ab0GFCCx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jul 2010 22:02:53 -0400
In-Reply-To: <f5d438863bb1132293cb6eab89fe199a739e4957.1278307573.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Mon, 5 Jul 2010 07:32:52 +0200

> This patch adds a new networking option to allow hardware time stamps
> from PHY devices. Using PHY time stamps will still require adding two
> inline function calls to each MAC driver. The CONFIG option makes
> these calls safe to add, since the calls become NOOPs when the option
> is disabled.
> 
> The patch also adds phylib driver methods for the SIOCSHWTSTAMP ioctl
> and callbacks for transmit and receive time stamping. Drivers may
> optionally implement these functions.
> 
> Signed-off-by: Richard Cochran <richard.cochran@omicron.at>

Applied.
