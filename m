From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [Patch net-next 4/5] net_sched: forbid setting default qdisc to
 inappropriate ones
Date: Sun, 30 Aug 2015 15:07:23 -0400
Message-ID: <55E3546B.8000605@mojatatu.com>
References: <CAM_iQpWap83uA1CsR5rryLEoc4ffrJp3+=zPs+uAAhAtkKtG_w@mail.gmail.com>
 <20150827.212359.1624170801280596846.davem@davemloft.net>
 <CAM_iQpVqgFMoKE8JGpHw3e+YTqRoVYADoKBprFaaV-Es=uDKdQ@mail.gmail.com>
 <20150828.162037.473306692661391284.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: David Miller <davem@davemloft.net>, xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:33215 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753611AbbH3TH1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Aug 2015 15:07:27 -0400
Received: by igbuu8 with SMTP id uu8so35138031igb.0
        for <netdev@vger.kernel.org>; Sun, 30 Aug 2015 12:07:27 -0700 (PDT)
In-Reply-To: <20150828.162037.473306692661391284.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/28/15 19:20, David Miller wrote:

> But HTB definitely should be allowed.

Problem with most non-work conserving schedulers is what the meaning
of default resources means; example, for HTB:
What is the default bandwidth you allocate to a class of users?

cheers,
jamal
