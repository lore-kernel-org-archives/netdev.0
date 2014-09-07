From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/3] net: bpf: consolidate JIT binary allocator
Date: Sun, 07 Sep 2014 16:15:43 -0700 (PDT)
Message-ID: <20140907.161543.2206530539028176158.davem@davemloft.net>
References: <1409996567-2170-1-git-send-email-dborkman@redhat.com>
	<1409996567-2170-2-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, netdev@vger.kernel.org, edumazet@google.com,
	heiko.carstens@de.ibm.com, schwidefsky@de.ibm.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56558 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752721AbaIGXPo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Sep 2014 19:15:44 -0400
In-Reply-To: <1409996567-2170-2-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Sat,  6 Sep 2014 11:42:45 +0200

> While reviewing the code, I think on s390, the alignment masking
> seems not to be correct in it's current form, that is, we make sure
> the first instruction starts at an even address as stated by commit
> aa2d2c73c21f but masks the start with '& -2' while 2 byte-alignment
> should rather be '& ~1'.

Both -2 and ~1 are the same value.
