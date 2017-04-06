From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: listen on the sock only when it's state is
 listening or closed
Date: Thu, 06 Apr 2017 13:56:18 -0700 (PDT)
Message-ID: <20170406.135618.1664330530425584626.davem@davemloft.net>
References: <19f73778f8e27b05ee9aa25ece57db6b0e73d197.1491455452.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        marcelo.leitner@gmail.com, nhorman@tuxdriver.com,
        andreyknvl@google.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38374 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751581AbdDFU4V (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 6 Apr 2017 16:56:21 -0400
In-Reply-To: <19f73778f8e27b05ee9aa25ece57db6b0e73d197.1491455452.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Thu,  6 Apr 2017 13:10:52 +0800

> Now sctp doesn't check sock's state before listening on it. It could
> even cause changing a sock with any state to become a listening sock
> when doing sctp_listen.
> 
> This patch is to fix it by checking sock's state in sctp_listen, so
> that it will listen on the sock with right state.
> 
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Tested-by: Andrey Konovalov <andreyknvl@google.com>
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied and queued up for -stable.
