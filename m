From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] samples/bpf: fix bpf tunnel cleanup
Date: Mon, 31 Jul 2017 22:02:59 -0700 (PDT)
Message-ID: <20170731.220259.2056237149923854705.davem@davemloft.net>
References: <1501537250-26371-1-git-send-email-u9012063@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: u9012063@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51472 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751038AbdHAFC7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 01:02:59 -0400
In-Reply-To: <1501537250-26371-1-git-send-email-u9012063@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: William Tu <u9012063@gmail.com>
Date: Mon, 31 Jul 2017 14:40:50 -0700

> test_tunnel_bpf.sh fails to remove the vxlan11 tunnel device, causing the
> next geneve tunnelling test case fails.  In addition, the geneve reserved bit
> in tcbpf2_kern.c should be zero, according to the RFC.
> 
> Signed-off-by: William Tu <u9012063@gmail.com>

Applied, thank you.
