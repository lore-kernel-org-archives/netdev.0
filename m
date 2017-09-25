From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] bpf: Optimize lpm trie delete
Date: Mon, 25 Sep 2017 14:38:20 -0700 (PDT)
Message-ID: <20170925.143820.627390178911789605.davem@davemloft.net>
References: <20170921224329.101928-1-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@zonque.org, ast@fb.com, daniel@iogearbox.net,
        netdev@vger.kernel.org
To: kraigatgoog@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60726 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934892AbdIYViU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 17:38:20 -0400
In-Reply-To: <20170921224329.101928-1-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraigatgoog@gmail.com>
Date: Thu, 21 Sep 2017 18:43:29 -0400

> From: Craig Gallek <kraig@google.com>
> 
> Before the delete operator was added, this datastructure maintained
> an invariant that intermediate nodes were only present when necessary
> to build the tree.  This patch updates the delete operation to reinstate
> that invariant by removing unnecessary intermediate nodes after a node is
> removed and thus keeping the tree structure at a minimal size.
> 
> Suggested-by: Daniel Mack <daniel@zonque.org>
> Signed-off-by: Craig Gallek <kraig@google.com>

Applied, thank you.
