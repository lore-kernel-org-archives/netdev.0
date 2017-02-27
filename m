From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] l2tp: avoid use-after-free caused by
 l2tp_ip_backlog_recv
Date: Sun, 26 Feb 2017 22:58:10 -0500 (EST)
Message-ID: <20170226.225810.2068448520693487748.davem@davemloft.net>
References: <20170226165819.27660-1-phueber@kernsp.in>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: phueber@kernsp.in
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34400 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751327AbdB0ExM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 26 Feb 2017 23:53:12 -0500
In-Reply-To: <20170226165819.27660-1-phueber@kernsp.in>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Hüber <phueber@kernsp.in>
Date: Sun, 26 Feb 2017 17:58:19 +0100

> l2tp_ip_backlog_recv may not return -1 if the packet gets dropped.
> The return value is passed up to ip_local_deliver_finish, which treats
> negative values as an IP protocol number for resubmission.
> 
> Signed-off-by: Paul Hüber <phueber@kernsp.in>

Applied and queued up for -stable, thanks.
