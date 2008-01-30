From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bugme-new] [Bug 9825] New: GPF in kernel when /sbin/ss used for display DCCP sockets.
Date: Wed, 30 Jan 2008 13:46:38 +1100
Message-ID: <E1JK2yE-000644-00@gondolin.me.apana.org.au>
References: <20080126223330.204e1bd1.akpm@linux-foundation.org>
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	spike@ml.yaroslavl.ru
To: akpm@linux-foundation.org (Andrew Morton)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:48810 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752875AbYA3Cqq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2008 21:46:46 -0500
In-Reply-To: <20080126223330.204e1bd1.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton <akpm@linux-foundation.org> wrote:
>
>> Jan 26 23:38:03 host general protection fault: 0000 [#1] PREEMPT
>> Jan 26 23:38:03 host Modules linked in: iptable_mangle iptable_nat nf_nat
>> ipt_REJECT xt_tcpudp nf_conntrack_ipv4 xt_state ipt_ULOG iptable_filter
>> ip_tables x_
>> Jan 26 23:38:03 host
>> Jan 26 23:38:03 host Pid: 5573, comm: ss Not tainted (2.6.24 #1)
>> Jan 26 23:38:03 host EIP: 0060:[<c031a14f>] EFLAGS: 00010282 CPU: 0
>> Jan 26 23:38:03 host EIP is at inet_diag_dump+0x2a/0x88b

This should be fixed by

	[PATCH][INET_DIAG]: Fix inet_diag_lock_handler error path
	20080128022050.GQ27661@ghostprotocols.net

that Arnaldo posted recently.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
