From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH net-next] sctp: Don't abort initialization when CONFIG_PROC_FS=n
Date: Wed, 16 Jul 2008 09:35:47 -0400
Message-ID: <487DF933.6000505@hp.com>
References: <1215954560-31702-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:34931 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756183AbYGPNhO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2008 09:37:14 -0400
In-Reply-To: <1215954560-31702-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Westphal wrote:
> This puts CONFIG_PROC_FS defines around the proc init/exit functions
> and also avoids compiling proc.c if procfs is not supported.
> Also make SCTP_DBG_OBJCNT depend on procfs.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

applied.  Thanks.

-vlad
