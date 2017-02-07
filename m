From: David Miller <davem@davemloft.net>
Subject: netvsc merge conflicts...
Date: Tue, 07 Feb 2017 16:41:41 -0500 (EST)
Message-ID: <20170207.164141.2253747431048804570.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58370 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932378AbdBGVu7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 16:50:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Stephen, I just did a merge of net into net-next and had to
resolve a merge conflict in the netvsc driver.

The problem was that in 'net' the hyperv bug fix that added
the calls to "init_cache_read_index()" in netvsc_channel_cb()
collided with your RX path cleanups.

Please double check my work and send me any needed fixups.

Thanks!
