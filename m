From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] TCP: increase default initial receive window.
Date: Fri, 17 Dec 2010 21:13:09 -0800 (PST)
Message-ID: <20101217.211309.226761639.davem@davemloft.net>
References: <1292642451-892-1-git-send-email-nanditad@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com, chavey@google.com,
	ycheng@google.com
To: nanditad@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48745
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750721Ab0LRFMk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Dec 2010 00:12:40 -0500
In-Reply-To: <1292642451-892-1-git-send-email-nanditad@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nandita Dukkipati <nanditad@google.com>
Date: Fri, 17 Dec 2010 19:20:51 -0800

> This patch changes the default initial receive window to 10 mss
> (defined constant). The default window is limited to the maximum
> of 10*1460 and 2*mss (when mss > 1460).
> 
> Signed-off-by: Nandita Dukkipati <nanditad@google.com>

That's an incredibly terse explanation for a very non-trivial
change with very non-trivial implications.

What analysis have you performed to lead you to decide that this
was a reasonable change to make?  Where can people see that
analysis and look over it to see if they agree with your
assesment of the data?

We can't apply a patch like that without any form of analysis or
reasoning.

You don't say "why" you're doing this, and frankly that really
ticks me off.
