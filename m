From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sctp: change to use uint<size>_t in uapi
 sctp.h
Date: Tue, 14 Feb 2017 11:26:04 -0500 (EST)
Message-ID: <20170214.112604.827348279100654183.davem@davemloft.net>
References: <05fb9cd9aed85d33cc8d635a18b0dcd3e7c0ff29.1487060628.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        marcelo.leitner@gmail.com, nhorman@tuxdriver.com,
        vyasevich@gmail.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35450 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752976AbdBNQ0L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 11:26:11 -0500
In-Reply-To: <05fb9cd9aed85d33cc8d635a18b0dcd3e7c0ff29.1487060628.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Tue, 14 Feb 2017 16:23:48 +0800

> All structures in uapi sctp.h are exported for userspace, their members'
> types should use uint<size>_t instead of __u<size>.

This is not true.

__u<size> is in fact preferred for userspace exported datastructures.
