From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] tg3: Expand 5719 workaround
Date: Fri, 11 Feb 2011 11:35:45 -0800 (PST)
Message-ID: <20110211.113545.246522442.davem@davemloft.net>
References: <1297450480-5998-1-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57521
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757513Ab1BKTfJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Feb 2011 14:35:09 -0500
In-Reply-To: <1297450480-5998-1-git-send-email-mcarlson@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Fri, 11 Feb 2011 10:54:40 -0800

> The previous patch applied cleanly for me, but here it is for net-2.6.

I'm not making it up, this one fails too:

davem@sunset:~/src/GIT/net-2.6$ git apply --check --whitespace=error-all diff
error: patch failed: drivers/net/tg3.c:13318
error: drivers/net/tg3.c: patch does not apply

GIT wants the line numbers to match up exactly, no fuzz is allowed.
