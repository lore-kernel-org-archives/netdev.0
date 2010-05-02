From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix compile error due to double return type in
 SOCK_DEBUG
Date: Sun, 02 May 2010 13:43:09 -0700 (PDT)
Message-ID: <20100502.134309.73368055.davem@davemloft.net>
References: <1272823202-25957-1-git-send-email-jengelh@medozas.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jengelh@medozas.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48720
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758595Ab0EBUnG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 May 2010 16:43:06 -0400
In-Reply-To: <1272823202-25957-1-git-send-email-jengelh@medozas.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Engelhardt <jengelh@medozas.de>
Date: Sun,  2 May 2010 20:00:01 +0200

> Fix this one:
> include/net/sock.h: error: two or more data types in declaration specifiers
> 
> Signed-off-by: Jan Engelhardt <jengelh@medozas.de>

Applied, thanks Jan.

Shows how many people actually try to mess with that ifdef.
I think we should just kill it off.
