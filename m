From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net] bnx2x: guard stats_pending with stats_lock in all cases
Date: Tue, 13 Aug 2013 13:57:26 -0400
Message-ID: <CADVnQy=H8b=z6HRm-QevyLVnLzShkqD7bufnt5gM_PbTx1YnHw@mail.gmail.com>
References: <1376334499-25192-1-git-send-email-ncardwell@google.com>
	<CAM8tLiPUO2EHMM7AZJrj=LfZqCBnpKMbHT9wWomBAp6v_18YYg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eilon Greenstein <eilong@broadcom.com>,
	Vladislav Zolotarov <vladz@broadcom.com>,
	Yaniv Rosner <yanivr@broadcom.com>,
	Merav Sicron <meravs@broadcom.com>,
	Eric Dumazet <edumazet@google.com>,
	Tom Herbert <therbert@google.com>,
	Havard Skinnemoen <hskinnemoen@google.com>,
	Sanjay Hortikar <horti@google.com>,
	Dmitry Kravkov <dmitry@broadcom.com>
To: Dmitry Kravkov <dkravkov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f49.google.com ([74.125.83.49]:52582 "EHLO
	mail-ee0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757355Ab3HMR52 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 13:57:28 -0400
Received: by mail-ee0-f49.google.com with SMTP id d41so4298844eek.8
        for <netdev@vger.kernel.org>; Tue, 13 Aug 2013 10:57:26 -0700 (PDT)
In-Reply-To: <CAM8tLiPUO2EHMM7AZJrj=LfZqCBnpKMbHT9wWomBAp6v_18YYg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 12, 2013 at 4:52 PM, Dmitry Kravkov <dkravkov@gmail.com> wrote:
> Neal, thanks for looking into this.
>
> There's another race, where two flows
> stats_update() and stats_start() may send two queries in parallel
> which will cause FW to assert.
>
> I'm preparing the set for net, which includes the fix  for this race
> also(will be out in a couple of hours)
>
> I will be more than happy if you will take a look.
>
> Thanks
> Dmitry

Thanks! Your "bnx2x: protect different statistics flows" patch looks
like a superset of the synchronization I was proposing in this patch,
so we can drop mine.

Thanks,
neal
