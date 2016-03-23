From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC 2/9] udp: Add noreference lookup functions
Date: Wed, 23 Mar 2016 16:28:56 -0700
Message-ID: <1458775736.10868.55.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1458772618-845742-1-git-send-email-tom@herbertland.com>
	 <1458772618-845742-3-git-send-email-tom@herbertland.com>
	 <1458773986.10868.54.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CALx6S35pPLoyY6hiOg1WKKe4FUATgJQncWvoxJe-Z2NoOMe2eA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:33538 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751163AbcCWX27 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2016 19:28:59 -0400
Received: by mail-pf0-f171.google.com with SMTP id 4so42145155pfd.0
        for <netdev@vger.kernel.org>; Wed, 23 Mar 2016 16:28:58 -0700 (PDT)
In-Reply-To: <CALx6S35pPLoyY6hiOg1WKKe4FUATgJQncWvoxJe-Z2NoOMe2eA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-03-23 at 16:17 -0700, Tom Herbert wrote:
> Thanks Eric. Do you think it is reasonable to not use
> SLAB_DESTROY_BY_RCU for UDP since it probably has a much lower
> allocation rate than what we'd see in TCP?

This is absolutely reasonable ;)
