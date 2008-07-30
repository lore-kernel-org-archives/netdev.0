From: David Miller <davem@davemloft.net>
Subject: Re: [patch 09/11] irda: replace __FUNCTION__ with __func__
Date: Wed, 30 Jul 2008 16:42:36 -0700 (PDT)
Message-ID: <20080730.164236.246400895.davem@davemloft.net>
References: <200807301937.m6UJbgXw012455@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, harvey.harrison@gmail.com,
	samuel@sortiz.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40188
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1761415AbYG3Xmg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 19:42:36 -0400
In-Reply-To: <200807301937.m6UJbgXw012455@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Wed, 30 Jul 2008 12:37:42 -0700

> From: Harvey Harrison <harvey.harrison@gmail.com>
> 
> __FUNCTION__ is gcc-specific, use __func__
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> Cc: Samuel Ortiz <samuel@sortiz.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

This gets rejects because it conflicts with the down_try()
changes that went into Linus's tree recently.  Specifically
this occurs in sir_dev.c
