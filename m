From: linux@horizon.com
Subject: Re: [PATCH 1/3] drivers/net/ipg.c: Fix skbuff leak
Date: 8 Jan 2008 08:19:56 -0500
Message-ID: <20080108131956.13905.qmail@science.horizon.com>
References: <20080108122814.12005.qmail@science.horizon.com>
Cc: akpm@linux-foundation.org, davem@davemloft.net, linux@horizon.com
To: netdev@vger.kernel.org, romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from science.horizon.com ([192.35.100.1]:11754 "HELO
	science.horizon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753197AbYAHNoP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 08:44:15 -0500
In-Reply-To: <20080108122814.12005.qmail@science.horizon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I take that back.  This patch does NOT fix the leak, at least if
ping: sendmsg: No buffer space available
is any indication...

I think I was reading slabinfo wrong.
kmalloc-2048       42111  42112   2048    4    2 : tunables    0    0    0 : slabdata  10528  10528      0

Sorry for the false hope.
