From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net-next 4/5] net_sched: forbid setting default qdisc to
 inappropriate ones
Date: Fri, 28 Aug 2015 08:26:53 -0400
Message-ID: <55E0538D.80502@mojatatu.com>
References: <CAM_iQpWscW+F4pnDXwn6uVsyaxVrYmUL6c8YF4wam29Lb4SVvg@mail.gmail.com>
 <20150827.161850.712938458604844308.davem@davemloft.net>
 <CAM_iQpWap83uA1CsR5rryLEoc4ffrJp3+=zPs+uAAhAtkKtG_w@mail.gmail.com>
 <20150827.212359.1624170801280596846.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: David Miller <davem@davemloft.net>, xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:33828 "EHLO
	mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752360AbbH1M04 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 08:26:56 -0400
Received: by iofe124 with SMTP id e124so25339259iof.1
        for <netdev@vger.kernel.org>; Fri, 28 Aug 2015 05:26:55 -0700 (PDT)
In-Reply-To: <20150827.212359.1624170801280596846.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/28/15 00:23, David Miller wrote:

> If a default qdisc like HTB is choosen, we invoke the ->init() function
> and we change the HTB ->init() function to do something reasonable
> if a NULL set of configuration attributes is given.  ie. make HTB use
> some defaults.
>

That may work. Or to reduce ambiguity introduce qdisc->set_default().

cheers,
jamal
