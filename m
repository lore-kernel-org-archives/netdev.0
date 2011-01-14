From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/7 v2] GRETH: handle frame error interrupts
Date: Fri, 14 Jan 2011 12:46:55 -0800 (PST)
Message-ID: <20110114.124655.08965086.davem@davemloft.net>
References: <1295010163-2585-1-git-send-email-daniel@gaisler.com>
	<1295010163-2585-6-git-send-email-daniel@gaisler.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kristoffer@gaisler.com
To: daniel@gaisler.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51188
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752168Ab1ANUqW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jan 2011 15:46:22 -0500
In-Reply-To: <1295010163-2585-6-git-send-email-daniel@gaisler.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Hellstrom <daniel@gaisler.com>
Date: Fri, 14 Jan 2011 14:02:42 +0100

> Frame error interrupts must also be handled since the RX flag only indicates
> successful reception, it is unlikely but the old code may lead to dead lock
> if 128 error frames are recieved in a row.
> 
> Signed-off-by: Daniel Hellstrom <daniel@gaisler.com>

Applied.
