From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] samples/bpf: run cleanup routines when receiving
 SIGTERM
Date: Thu, 11 May 2017 21:43:46 -0400 (EDT)
Message-ID: <20170511.214346.76939954403260957.davem@davemloft.net>
References: <1494532350-23945-1-git-send-email-andy@greyhouse.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shahid.habib@broadcom.com
To: andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56868 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756925AbdELBns (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 11 May 2017 21:43:48 -0400
In-Reply-To: <1494532350-23945-1-git-send-email-andy@greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Gospodarek <andy@greyhouse.net>
Date: Thu, 11 May 2017 15:52:30 -0400

> Shahid Habib noticed that when xdp1 was killed from a different console the xdp
> program was not cleaned-up properly in the kernel and it continued to forward
> traffic.
> 
> Most of the applications in samples/bpf cleanup properly, but only when getting
> SIGINT.  Since kill defaults to using SIGTERM, add support to cleanup when the
> application receives either SIGINT or SIGTERM.
> 
> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> Reported-by: Shahid Habib <shahid.habib@broadcom.com>

Applied, thanks Andy.
