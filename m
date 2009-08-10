From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: fix missing destroy of percpu counter variable
 in sctp_proc_exit()
Date: Sun, 09 Aug 2009 21:49:59 -0700 (PDT)
Message-ID: <20090809.214959.170043474.davem@davemloft.net>
References: <1249658237-9031-1-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rlaufer@cisco.com
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59244
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751463AbZHJEtt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2009 00:49:49 -0400
In-Reply-To: <1249658237-9031-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Fri,  7 Aug 2009 11:17:17 -0400

> From: Rafael Laufer <rlaufer@cisco.com>
> 
> Commit 1748376b6626acf59c24e9592ac67b3fe2a0e026,
> 	net: Use a percpu_counter for sockets_allocated
> 
> added percpu_counter function calls to sctp_proc_init code path, but
> forgot to add them to sctp_proc_exit().  This resulted in a following
> Ooops when performing this test
 ...
> Signed-off-by: Rafael Laufer <rlaufer@cisco.com>
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied.
