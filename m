From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] skbuff: remove unused variable `doff'
Date: Tue, 10 May 2016 16:05:37 -0400 (EDT)
Message-ID: <20160510.160537.616493388343705651.davem@davemloft.net>
References: <20160510163808.GN13183@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43074 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751384AbcEJUFj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2016 16:05:39 -0400
In-Reply-To: <20160510163808.GN13183@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Tue, 10 May 2016 12:38:08 -0400

> There are two instances of an unused variable, `doff' added by
> commit 6fa01ccd8830 ("skbuff: Add pskb_extract() helper function")
> in pskb_carve_inside_header() and pskb_carve_inside_nonlinear().
> Remove these instances, they are not used.
> 
> Reported by: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>

Applied.
