From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] fib_trie: rcu_assign_pointer warning fix
Date: Tue, 12 Feb 2008 20:46:30 +0100
Message-ID: <20080212194630.GB2803@ami.dom.local>
References: <20080211.171645.74019568.davem@davemloft.net> <20080212085714.GB2582@ff.dom.local> <20080212160729.GA9157@linux.vnet.ibm.com> <20080212193218.GA2803@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:33565 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763340AbYBLTm5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2008 14:42:57 -0500
Received: by ug-out-1314.google.com with SMTP id z38so588533ugc.16
        for <netdev@vger.kernel.org>; Tue, 12 Feb 2008 11:42:56 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080212193218.GA2803@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 12, 2008 at 08:32:18PM +0100, Jarek Poplawski wrote:
...
> It seems the above version of this macro uses the barrier for 0, but
> if I miss something, or for these other: documenting reasons,

...or __builtin_constants could be used for indexing (?!),

> then of
> course you are right.

Jarek P.
