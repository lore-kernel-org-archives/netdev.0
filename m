From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/8] tg3: Bugfixes and updates
Date: Fri, 01 Oct 2010 00:26:28 -0700 (PDT)
Message-ID: <20101001.002628.267960834.davem@davemloft.net>
References: <1285878877-12148-1-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39454
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751799Ab0JAH0H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Oct 2010 03:26:07 -0400
In-Reply-To: <1285878877-12148-1-git-send-email-mcarlson@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Thu, 30 Sep 2010 13:34:29 -0700

> This patchset implements some bugfixes, removes the 5724 device
> ID and introduces extended rx buffer rings.

All applied....

But really, I want to hear some real justification for a 2048 entry RX
ring at gigabit speeds.  I even think 512 is way too large for gigabit
parts.

Any machine that gets one of these newer 5717 parts does not need that
much queueing, and too deep queues tend to hurt locality and thus
performance.
