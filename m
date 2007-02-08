From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH 4/5] NET : Convert decnet route to use the new dst_entry 'next'
 pointer
Date: Thu, 08 Feb 2007 22:39:28 +0100
Message-ID: <45CB9890.40501@cosmosbay.com>
References: <20070202120528.GA10392@de.ibm.com> <20070206.144106.39659974.davem@davemloft.net> <45C9093D.1030605@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:58001 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423444AbXBHVjk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Feb 2007 16:39:40 -0500
In-Reply-To: <45C9093D.1030605@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch removes the next pointer from 'struct rt6_info.u' union, and 
renames u.next to u.dst.rt6_next.

It also moves 'struct flowi' right after 'struct dst_entry' to prepare speedup 
lookups.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

