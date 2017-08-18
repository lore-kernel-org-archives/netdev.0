From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V4 net 0/2] ipv6: fix flowlabel issue for reset packet
Date: Fri, 18 Aug 2017 15:27:09 -0700 (PDT)
Message-ID: <20170818.152709.1530391846414055080.davem@davemloft.net>
References: <20170817225521.ybb7cclaxs6skdem@kafai-mba.dhcp.thefacebook.com>
        <CALx6S3498iPfNs4Wt5RWjoxZS0nXHT=qvdSgZhZbqxswqJqdZw@mail.gmail.com>
        <20170818205136.nsmlmyshaobsyukc@kafai-mba.dhcp.thefacebook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, shli@kernel.org, netdev@vger.kernel.org
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33868 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750847AbdHRW1K (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 18:27:10 -0400
In-Reply-To: <20170818205136.nsmlmyshaobsyukc@kafai-mba.dhcp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin KaFai Lau <kafai@fb.com>
Date: Fri, 18 Aug 2017 13:51:36 -0700

> It seems like that middle box specifically drops TCP_RST if it
> does not know anything about this flow.  Since the flowlabel of the TCP_RST
> (sent in TW state) is always different, it always lands to a different middle
> box.  All of these TCP_RST cannot be delivered.

This really is illegal behavior.  The flow label is not a flow _KEY_
by any definition whatsoever.

Flow labels are an optimization, not a determinant for flow matching
particularly for proper TCP state processing.

I'd rather you invest all of this energy getting that vendor to fix
their kit.

Thank you.
