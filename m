From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] selftests: correct define in msg_zerocopy.c
Date: Fri, 01 Sep 2017 10:41:31 -0700 (PDT)
Message-ID: <20170901.104131.458901946836313233.davem@davemloft.net>
References: <20170901163151.106867-1-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@fb.com, dmm@fb.com, willemb@google.com
To: willemdebruijn.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50206 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752148AbdIARlc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 13:41:32 -0400
In-Reply-To: <20170901163151.106867-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Date: Fri,  1 Sep 2017 12:31:51 -0400

> From: Willem de Bruijn <willemb@google.com>
> 
> The msg_zerocopy test defines SO_ZEROCOPY if necessary, but its value
> is inconsistent with the one in asm-generic.h. Correct that.
> 
> Also convert one error to a warning. When the test is complete, report
> throughput and close cleanly even if the process did not wait for all
> completions.
> 
> Reported-by: Dan Melnic <dmm@fb.com>
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Applied.
