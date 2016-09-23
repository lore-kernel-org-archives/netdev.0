From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] act_ife: Add support for machines with
 hard_header_len != mac_len
Date: Fri, 23 Sep 2016 07:05:36 -0400 (EDT)
Message-ID: <20160923.070536.1880911510074184857.davem@davemloft.net>
References: <1474462453-37668-1-git-send-email-yotamg@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, netdev@vger.kernel.org
To: yotamg@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51016 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938722AbcIWLFj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 07:05:39 -0400
In-Reply-To: <1474462453-37668-1-git-send-email-yotamg@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>
Date: Wed, 21 Sep 2016 15:54:13 +0300

> Without that fix, the following could occur:
 ...

I don't think what you are doing in mlxsw is valid.

You can't set hard_header_len arbitrarily, it's the MAC length.

If you need to prepend special headers or whatever, set
->needed_headroom which is designed for this purpose.

Thanks.
