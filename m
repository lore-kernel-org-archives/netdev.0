From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf-next] netfilter: nf_defrag_ipv4: Drop redundant
 ip_send_check()
Date: Tue, 1 Mar 2016 20:42:26 +0100
Message-ID: <20160301194225.GA2815@salvia>
References: <1454522410-24976-1-git-send-email-joe@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	linux-kernel@vger.kernel.org, edjee@google.com, edumazet@google.com
To: Joe Stringer <joe@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:43292 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752236AbcCATmd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Mar 2016 14:42:33 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id F072E7419
	for <netdev@vger.kernel.org>; Tue,  1 Mar 2016 20:42:29 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id D9964DA8F7
	for <netdev@vger.kernel.org>; Tue,  1 Mar 2016 20:42:29 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 60750DA383
	for <netdev@vger.kernel.org>; Tue,  1 Mar 2016 20:42:27 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <1454522410-24976-1-git-send-email-joe@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 03, 2016 at 10:00:10AM -0800, Joe Stringer wrote:
> Since commit 0848f6428ba3 ("inet: frags: fix defragmented packet's IP
> header for af_packet"), ip_send_check() would be called twice for
> defragmentation that occurs from netfilter ipv4 defrag hooks. Remove the
> extra call.

Applied, thanks Joe.
