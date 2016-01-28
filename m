From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] fix the transport dead race check by using
 atomic_add_unless on refcnt
Date: Thu, 28 Jan 2016 15:59:59 -0800 (PST)
Message-ID: <20160128.155959.916092147593687503.davem@davemloft.net>
References: <cover.1453398443.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	marcelo.leitner@gmail.com, vyasevich@gmail.com,
	daniel@iogearbox.net
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59955 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751055AbcA2AAA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 19:00:00 -0500
In-Reply-To: <cover.1453398443.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Fri, 22 Jan 2016 01:49:06 +0800

> Xin Long (3):
>   sctp: fix the transport dead race check by using atomic_add_unless on
>     refcnt
>   sctp: hold transport before we access t->asoc in sctp proc
>   sctp: remove the dead field of sctp_transport

Applied, thanks.
