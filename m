From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] seeq: use PTR_RET at init_module of driver
Date: Sun, 29 Jul 2012 23:19:33 -0700 (PDT)
Message-ID: <20120729.231933.1313580585826576588.davem@davemloft.net>
References: <1343568527-12729-1-git-send-email-develkernel412222@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, dhowells@redhat.com,
	jpirko@redhat.com, netdev@pradeepdalvi.com, netdev@vger.kernel.org
To: develkernel412222@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50765 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753235Ab2G3GTe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2012 02:19:34 -0400
In-Reply-To: <1343568527-12729-1-git-send-email-develkernel412222@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Devendra Naga <develkernel412222@gmail.com>
Date: Sun, 29 Jul 2012 19:13:47 +0545

> the driver sees wether the dev_seeq pointer is having a error that can be
> read by using the PTR_ERR, and returns it at error case, other wise 0 at
> success case.
> 
> the PTR_RET does the same thing, and use PTR_RET instead of redoing the
> code of PTR_RET
> 
> Signed-off-by: Devendra Naga <develkernel412222@gmail.com>

Applied.
