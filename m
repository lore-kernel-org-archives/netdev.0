From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/2] bonding: use l4 hash if available
Date: Tue, 15 Sep 2015 19:31:58 -0700
Message-ID: <1442370718.4116.43.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1442355868.4116.14.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CALx6S36gs8qC5UXjowoDShZif=81BMJQjUyR_mn4JTaH6xE43w@mail.gmail.com>
	 <1442361832.4116.21.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CALx6S37WgoNp-mgSHFmDc0dW1ozKt-5kNV4+j4oPekebVz8JVQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35430 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751772AbbIPCcA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2015 22:32:00 -0400
Received: by pacfv12 with SMTP id fv12so197674271pac.2
        for <netdev@vger.kernel.org>; Tue, 15 Sep 2015 19:32:00 -0700 (PDT)
In-Reply-To: <CALx6S37WgoNp-mgSHFmDc0dW1ozKt-5kNV4+j4oPekebVz8JVQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-09-15 at 17:15 -0700, Tom Herbert wrote:

> A more fundamental question is whether we can eliminate some of these
> hashing types (I see five of them in if_bonding.h). Is there any
> substantial difference between this and IPv4/v6 ECMP routing such that
> they shouldn't all have the same path selection modes?

We had an issue on a router that did not like a change in the hashing
done by the host behind it.

Do not ask me for details that I cannot provide, but I would guess it is
better not changing legacy modes unilaterally.
