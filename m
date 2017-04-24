From: David Miller <davem@davemloft.net>
Subject: test_progs packed...
Date: Mon, 24 Apr 2017 19:06:01 -0400 (EDT)
Message-ID: <20170424.190601.2066346847263955701.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, kafai@fb.com, netdev@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58956 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936408AbdDXXGJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 19:06:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Alexei, why the packed attribute usage in test_progs.c?

There should be no reason for this and it results in the object(s)
having odd addresses (and thus be unaligned) on sparc.
