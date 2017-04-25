From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] selftests/net: Fix broken test case in
 psock_fanout
Date: Tue, 25 Apr 2017 11:56:29 -0400 (EDT)
Message-ID: <20170425.115629.2245862027879936980.davem@davemloft.net>
References: <20170425012911.903-1-maloneykernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, maloney@google.com
To: maloneykernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41142 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1951075AbdDYP4a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 11:56:30 -0400
In-Reply-To: <20170425012911.903-1-maloneykernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Maloney <maloneykernel@gmail.com>
Date: Mon, 24 Apr 2017 21:29:11 -0400

> From: Mike Maloney <maloney@google.com>
> 
> The error return falue form sock_fanout_open is -1, not zero.  One test
> case was checking for 0 instead of -1.
> 
> Tested: Built and tested in clean client.
> Signed-off-by: Mike Maloney <maloney@google.com>

Applied, thanks.
