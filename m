From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix possible null pointer dereference in ariadne.c
Date: Tue, 01 Mar 2011 11:53:00 -0800 (PST)
Message-ID: <20110301.115300.112595321.davem@davemloft.net>
References: <1298979207-11237-1-git-send-email-huzaifas@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, geert@linux-m68k.org, tj@kernel.org,
	eric.dumazet@gmail.com
To: huzaifas@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42679
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755446Ab1CATwY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 14:52:24 -0500
In-Reply-To: <1298979207-11237-1-git-send-email-huzaifas@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: huzaifas@redhat.com
Date: Tue,  1 Mar 2011 17:03:27 +0530

> +    *lance = (struct Am79C960*)dev->base_addr;

If you had actually compiled this, the compiler would have given
you a warning shoing that the leading "*" in "*lance" is not
appropriate for this assignment.
