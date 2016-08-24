From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 net-next] net: diag: support SOCK_DESTROY for UDP
 sockets
Date: Tue, 23 Aug 2016 23:12:46 -0700 (PDT)
Message-ID: <20160823.231246.2084774748905175945.davem@davemloft.net>
References: <1472011593-16807-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lorenzo@google.com, eric.dumazet@gmail.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57468 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753302AbcHXGMr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 02:12:47 -0400
In-Reply-To: <1472011593-16807-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Tue, 23 Aug 2016 21:06:33 -0700

> This implements SOCK_DESTROY for UDP sockets similar to what was done
> for TCP with commit c1e64e298b8ca ("net: diag: Support destroying TCP
> sockets.") A process with a UDP socket targeted for destroy is awakened
> and recvmsg fails with ECONNABORTED.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied.
