From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 0/9] sockmap UAPI updates and fixes
Date: Mon, 28 Aug 2017 11:13:40 -0700 (PDT)
Message-ID: <20170828.111340.995355526422443420.davem@davemloft.net>
References: <20170828140850.14143.83953.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, daniel@iogearbox.net, netdev@vger.kernel.org
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44976 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751272AbdH1SNl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 14:13:41 -0400
In-Reply-To: <20170828140850.14143.83953.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Mon, 28 Aug 2017 07:09:45 -0700

> This series updates sockmap UAPI, adds additional test cases and
> provides a couple fixes.
> 
> First the UAPI changes. The original API added two sockmap specific
> API artifacts (a) a new map_flags field with a sockmap specific update
> command and (b) a new sockmap specific attach field in the attach data
> structure. After this series instead of attaching programs with a
> single command now two commands are used to attach programs to maps
> individually. This allows us to add new programs easily in the future
> and avoids any specific sockmap data structure additions. The
> map_flags field is also removed and instead we allow socks to be
> added to multiple maps that may or may not have programs attached.
> This allows users to decide if a sock should run a SK_SKB program type
> on receive based on the map it is attached to. This is a nice
> improvement. See patches for specific details.
> 
> More test cases were added to test above changes and also stress test
> the interface.
> 
> Finally two fixes/improvements were made. First a missing rcu
> section was added. Second now sockmap can build without KCM being
> used to trigger 'y' on CONFIG_STREAM_PARSER by selecting a new
> BPF config option.

Series applied, thanks John.
