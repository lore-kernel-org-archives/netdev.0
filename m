From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 001/001] ipv4: enable use of 240/4 address space
Date: Thu, 10 Jan 2008 22:33:37 -0800 (PST)
Message-ID: <20080110.223337.96558244.davem@davemloft.net>
References: <20080108011057.GA21168@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: vaf@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38847
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751208AbYAKGdi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2008 01:33:38 -0500
In-Reply-To: <20080108011057.GA21168@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vince Fuller <vaf@cisco.com>
Date: Mon, 7 Jan 2008 17:10:57 -0800

> from Vince Fuller <vaf@vaf.net>
> 
> This set of diffs modify the 2.6.20 kernel to enable use of the 240/4
> (aka "class-E") address space as consistent with the Internet Draft
> draft-fuller-240space-00.txt.
> 
> Signed-off-by: Vince Fuller <vaf@vaf.net>

There has been more than 90K worth of changes to the files you are
changing since 2.6.20

It is generally unwise to submit patches against such old kernel
versions, they rarely apply, so please respin your patch against more
current sources.

Please also remove the trailing whitespace, like the one found
here:

+#define	IN_CLASSE_HOST		(0xffffffff & ~IN_CLASSE_NET)
+
+/* 
   ^^^^^

Thanks.
