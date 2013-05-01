From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sctp: attribute printl with __printf for gcc fmt
 checks
Date: Wed, 01 May 2013 15:04:34 -0400 (EDT)
Message-ID: <20130501.150434.374516340554504821.davem@davemloft.net>
References: <1367413163-2817-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41706 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756186Ab3EATEg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 May 2013 15:04:36 -0400
In-Reply-To: <1367413163-2817-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Wed,  1 May 2013 14:59:23 +0200

> Let GCC check for format string errors in sctp's probe printl
> function. This patch fixes the warning when compiled with W=1:
> 
> net/sctp/probe.c:73:2: warning: function might be possible candidate
> for 'gnu_printf' format attribute [-Wmissing-format-attribute]
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied.
