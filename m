From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sctp: remove the old ttl expires policy
Date: Thu, 13 Oct 2016 09:44:56 -0400 (EDT)
Message-ID: <20161013.094456.2092429969925371125.davem@davemloft.net>
References: <db5df5806c3c0b7c37ab9039a906664a33c74563.1475898016.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        marcelo.leitner@gmail.com, vyasevich@gmail.com,
        daniel@iogearbox.net
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60776 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752434AbcJMNrH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 09:47:07 -0400
In-Reply-To: <db5df5806c3c0b7c37ab9039a906664a33c74563.1475898016.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Sat,  8 Oct 2016 11:40:16 +0800

> The prsctp polices include ttl expires policy already, we should remove
> the old ttl expires codes, and just adjust the new polices' codes to be
> compatible with the old one for users.
> 
> This patch is to remove all the old expires codes, and if prsctp polices
> are not set, it will still set msg's expires_at and check the expires in
> sctp_check_abandoned.
> 
> Note that asoc->prsctp_enable is set by default, so users can't feel any
> difference even if they use the old expires api in userspace.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied.
