From: Xufeng Zhang <xufengzhang.main@gmail.com>
Subject: Question about esp sequence number and anti-reply window logic
Date: Wed, 28 May 2014 10:30:16 +0800
Message-ID: <CA+=dFzhDVqRvFU0f8QoP7thV7LJeHN_375oe=dG=NoqoSGD1eQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f51.google.com ([209.85.192.51]:36777 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751966AbaE1CaR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2014 22:30:17 -0400
Received: by mail-qg0-f51.google.com with SMTP id q107so16042212qgd.10
        for <netdev@vger.kernel.org>; Tue, 27 May 2014 19:30:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

Per RFC4303:
The sender assumes anti-replay is enabled as a default, unless
otherwise notified by the receiver (see Section 3.4.3). Thus,
typical behavior of an ESP implementation calls for the sender to
establish a new SA when the Sequence Number (or ESN) cycles, or in
anticipation of this value cycling.

But currently the xfrm implementation don't establish a new SA when
the Sequence Number cycles, it just give a notification to user.
I know this might be a well-known limitation, but is there any document
declare this about why xfrm didn't implement this?

I also found a similar bug opened for this issue but without any response:
https://bugzilla.kernel.org/show_bug.cgi?id=76791


Thanks a lot!
Xufeng
