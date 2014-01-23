From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next 3/6] net_sched: act: hide struct tcf_common from API
Date: Wed, 22 Jan 2014 23:10:52 -0800
Message-ID: <CAM_iQpXRyQibP7+Zbxgpie7AfEAxZamZ6wSWDrnQbweRJEmnrQ@mail.gmail.com>
References: <1389987427-14085-1-git-send-email-xiyou.wangcong@gmail.com>
	<1389987427-14085-4-git-send-email-xiyou.wangcong@gmail.com>
	<52DD1E15.2040400@mojatatu.com>
	<52DFBD40.4090905@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f52.google.com ([209.85.219.52]:44449 "EHLO
	mail-oa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750927AbaAWHKw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 02:10:52 -0500
Received: by mail-oa0-f52.google.com with SMTP id i4so1706821oah.39
        for <netdev@vger.kernel.org>; Wed, 22 Jan 2014 23:10:52 -0800 (PST)
In-Reply-To: <52DFBD40.4090905@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 22, 2014 at 4:44 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> Cong,
>
> I applied the patches and run the tests below.
> The first one is broken for sure.
> The second one has different behavior - but then I rembered
> i had an offline discussion with you and i think this is fine.
>
> Please chase whatever these issues are and fix; if the tests pass
> you could go ahead and add my signed-off.
>

Hi, Jamal

I had similar tests locally, I will check why the first of your test
failed tomorrow.

For the second, yeah actions bound to a filter refuse to be removed
after my patches, this is intentional.

Thanks!
