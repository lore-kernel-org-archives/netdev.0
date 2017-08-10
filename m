From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1 net] TCP_USER_TIMEOUT and tcp_keepalive should
 conform to RFC5482
Date: Wed, 09 Aug 2017 17:30:32 -0700 (PDT)
Message-ID: <20170809.173032.660035274684914457.davem@davemloft.net>
References: <CAK6E8=ehu5uK6bsprzAQc-Nu6WS2YQEcktD0H2RrjgPpS47-Yg@mail.gmail.com>
        <CAPshTCgaYVPEbZxDr9sUz7OFibweQn6fwRtP66cgw5eNrHUOWA@mail.gmail.com>
        <CABGNeczGSsL6xj-SkXQYTWXXe+mJoyhvrQxuLkiO27pW0y8MtA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hkchu@google.com, ycheng@google.com, rao.shoaib@oracle.com,
        kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org
To: codesoldier1@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48366 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752174AbdHJAaf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 20:30:35 -0400
In-Reply-To: <CABGNeczGSsL6xj-SkXQYTWXXe+mJoyhvrQxuLkiO27pW0y8MtA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Smith <codesoldier1@gmail.com>
Date: Wed, 9 Aug 2017 17:20:32 -0700

> Making Linux conform to standards and behavior that is logical seems
> like a good enough reason.

That's an awesome attitude to have when we're implementing something
new and don't have the facility already.

But when we have something already the only important consideration is
not breaking existing apps which rely on that behavior.

That is much, much, more important than standards compliance.

If users are confused, just fix the documentation.
