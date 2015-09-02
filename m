From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next 4/5] net_sched: forbid setting default qdisc to
 inappropriate ones
Date: Tue, 1 Sep 2015 23:05:45 -0700
Message-ID: <CAM_iQpVS2qzPeJNfNY11XP-b3bJH1BAU2aa2H3hLzu+F-zKAOw@mail.gmail.com>
References: <CAM_iQpWap83uA1CsR5rryLEoc4ffrJp3+=zPs+uAAhAtkKtG_w@mail.gmail.com>
	<20150827.212359.1624170801280596846.davem@davemloft.net>
	<CAM_iQpVqgFMoKE8JGpHw3e+YTqRoVYADoKBprFaaV-Es=uDKdQ@mail.gmail.com>
	<20150828.162037.473306692661391284.davem@davemloft.net>
	<55E3546B.8000605@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:35868 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750984AbbIBGFq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 02:05:46 -0400
Received: by obqa2 with SMTP id a2so18371230obq.3
        for <netdev@vger.kernel.org>; Tue, 01 Sep 2015 23:05:45 -0700 (PDT)
In-Reply-To: <55E3546B.8000605@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 30, 2015 at 12:07 PM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 08/28/15 19:20, David Miller wrote:
>
>> But HTB definitely should be allowed.
>
>
> Problem with most non-work conserving schedulers is what the meaning
> of default resources means; example, for HTB:
> What is the default bandwidth you allocate to a class of users?
>

Exactly, that is why it has to need at least one parameter for bandwidth,
while default qdisc requires no parameter.
