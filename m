From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next 0/5] ip6: Transmit tunneling fixes
Date: Mon, 9 May 2016 20:30:46 -0700
Message-ID: <CAKgT0Ue_D0_nGuYQnrYfXBDdKb+ieUhZKcfnz_QxhN61mvReBw@mail.gmail.com>
References: <1462839132-980991-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:34349 "EHLO
	mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753013AbcEJDas (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 23:30:48 -0400
Received: by mail-io0-f172.google.com with SMTP id 190so2729593iow.1
        for <netdev@vger.kernel.org>; Mon, 09 May 2016 20:30:47 -0700 (PDT)
In-Reply-To: <1462839132-980991-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 9, 2016 at 5:12 PM, Tom Herbert <tom@herbertland.com> wrote:
> Several fixes suggested by Alexander.
>
> Tested: Running netperf TCP_STREAM with gretap and keyid configured.
> Visually verified that MTU is correctly being set. Did not test HW
> offload (Alexander plese try)

This appears to have fixed the issues I saw.  I can confirm the MTU is
the same value that it was before the regression and I am able to
send/receive at around 17Gb/s.

Tested-by: Alexander Duyck <aduyck@mirantis.com>
