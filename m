From: David Miller <davem@davemloft.net>
Subject: Re: [V2 PATCH net-next 0/2] Fixes for XDP_REDIRECT map
Date: Fri, 08 Sep 2017 20:54:26 -0700 (PDT)
Message-ID: <20170908.205426.624386613610674398.davem@davemloft.net>
References: <150478756604.28665.6915020425359475729.stgit@firesoul>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, borkmann@iogearbox.net,
        john.fastabend@gmail.com, andy@greyhouse.net
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43006 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753213AbdIIDy0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 23:54:26 -0400
In-Reply-To: <150478756604.28665.6915020425359475729.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Thu, 07 Sep 2017 14:33:08 +0200

> This my V2 of catching XDP_REDIRECT and bpf_redirect_map() API usage
> that can potentially crash the kernel.  Addressed Daniels feedback in
> patch01, and added patch02 which catch and cleanup dangling map
> pointers.
> 
> I know John and Daniel are working on a more long-term solution, of
> recording the bpf_prog pointer together with the map pointer.  I just
> wanted to propose these fixes as a stop-gap to the potential crashes.

Jesper if these are still relevant, please resubmit against the 'net'
tree, thanks!
