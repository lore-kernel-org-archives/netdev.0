From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] 3c59x: Acquire vortex lock instead of disabling irq
Date: Wed, 17 Mar 2010 11:27:06 -0700 (PDT)
Message-ID: <20100317.112706.143765408.davem@davemloft.net>
References: <1268836396-23943-2-git-send-email-chase.douglas@canonical.com>
	<20100317.110320.15445884.davem@davemloft.net>
	<40ec3ea41003171120x26d2e8b4q6b59c992ab28e454@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: chase.douglas@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34667
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751904Ab0CQS0p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Mar 2010 14:26:45 -0400
In-Reply-To: <40ec3ea41003171120x26d2e8b4q6b59c992ab28e454@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chase Douglas <chase.douglas@canonical.com>
Date: Wed, 17 Mar 2010 14:20:45 -0400

> If that's the case, what's the solution? It's not safe to call
> disable_irq* in softirq context anymore.

That's a huge problem, because such a restriction has broken
several drivers.  3c59x is not the only one which uses this
technique for this reason.  The 8390 one does too.

