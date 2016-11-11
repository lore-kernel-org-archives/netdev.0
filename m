From: Julia Lawall <julia.lawall@lip6.fr>
Subject: question about xt_find_table_lock
Date: Fri, 11 Nov 2016 11:49:57 +0100 (CET)
Message-ID: <alpine.DEB.2.20.1611111141380.2074@hadrien>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        christophe.jaillet@wanadoo.fr
To: pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
        davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3-relais-sop.national.inria.fr ([192.134.164.104]:64744
        "EHLO mail3-relais-sop.national.inria.fr" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755424AbcKKKuB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Nov 2016 05:50:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function xt_find_table_lock defined in net/netfilter/x_tables.c is
preceeded by a comment that says that it returns ERR_PTR() on error.  But
looking at the definition, I only see occurrences of return NULL and
returns of pointers that have previously been dereferenced.  Is it the
code or the documentation that is incorrect?  The call sites seem to be
using IS_ERR_OR_NULL.  Is there a plan to return ERR_PTR values in the
future?

julia
