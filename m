From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: Increment LISTENOVERFLOW and LISTENDROPS in
 tcp_v4_conn_request()
Date: Tue, 29 Jan 2013 15:46:09 -0500 (EST)
Message-ID: <20130129.154609.15063255396684128.davem@davemloft.net>
References: <1359431557-4587-1-git-send-email-niveditasinghvi@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, subramanian.vijay@gmail.com, niv@us.ibm.com
To: niveditasinghvi@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60107 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751033Ab3A2UqL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 15:46:11 -0500
In-Reply-To: <1359431557-4587-1-git-send-email-niveditasinghvi@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nivedita Singhvi <niveditasinghvi@gmail.com>
Date: Mon, 28 Jan 2013 19:52:37 -0800

> From: Nivedita Singhvi <niv@us.ibm.com>
> 
> We drop a connection request if the accept backlog is full and there are
> sufficient packets in the syn queue to warrant starting drops. Increment the
> appropriate counters so this isn't silent, for accurate stats and help in
> debugging.
> 
> This patch assumes LINUX_MIB_LISTENDROPS is a superset of/includes the
> counter LINUX_MIB_LISTENOVERFLOWS.
> 
> Signed-off-by: Nivedita Singhvi <niv@us.ibm.com>

Applied.
