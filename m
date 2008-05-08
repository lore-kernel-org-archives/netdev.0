From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 02/18] flag parameters: paccept
Date: Thu, 08 May 2008 15:50:03 -0700 (PDT)
Message-ID: <20080508.155003.122177149.davem@davemloft.net>
References: <200805062118.m46LI7SS004041@devserv.devel.redhat.com>
	<20080508153822.0c4dd6e9.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: drepper@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, davidel@xmailserver.org,
	mtk.manpages@gmail.com, torvalds@linux-foundation.org,
	roland@redhat.com, oleg@tv-sign.ru
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44368
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1762162AbYEHWuL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2008 18:50:11 -0400
In-Reply-To: <20080508153822.0c4dd6e9.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Thu, 8 May 2008 15:38:22 -0700

> Whatever you're trying to do here, we'll need to find a non-arch-specific
> way of doing it.

Probably: set_restore_sigmask();
