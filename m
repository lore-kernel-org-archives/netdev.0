From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: Fix regression introduced by new sctp_connectx
 api
Date: Fri, 13 Nov 2009 19:57:17 -0800 (PST)
Message-ID: <20091113.195717.177244655.davem@davemloft.net>
References: <1257963564-26376-1-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35593
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757708AbZKND5B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 22:57:01 -0500
In-Reply-To: <1257963564-26376-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Wed, 11 Nov 2009 13:19:24 -0500

> A new (unrealeased to the user) sctp_connectx api
> 
> c6ba68a26645dbc5029a9faa5687ebe6fcfc53e4
>     sctp: support non-blocking version of the new sctp_connectx() API
> 
> introduced a regression cought by the user regression test
> suite.  In particular, the API requires the user library to
> re-allocate the buffer and could potentially trigger a SIGFAULT.
> 
> This change corrects that regression by passing the original
> address buffer to the kernel unmodified, but still allows for
> a returned association id.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied.
