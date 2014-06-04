From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [Patch net-next] net: remove some useless list_del()
Date: Tue, 3 Jun 2014 19:18:10 -0700
Message-ID: <CAADnVQK+JUp63oETwazjkmouyQqn8ph9Ssbe=B6qhChcHgcgrw@mail.gmail.com>
References: <1401840715-16375-1-git-send-email-xiyou.wangcong@gmail.com>
	<1401840715-16375-2-git-send-email-xiyou.wangcong@gmail.com>
	<1401842581.3645.241.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f42.google.com ([209.85.216.42]:47960 "EHLO
	mail-qa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752110AbaFDCSL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 22:18:11 -0400
Received: by mail-qa0-f42.google.com with SMTP id j5so6278964qaq.1
        for <netdev@vger.kernel.org>; Tue, 03 Jun 2014 19:18:10 -0700 (PDT)
In-Reply-To: <1401842581.3645.241.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 3, 2014 at 5:43 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2014-06-03 at 17:11 -0700, Cong Wang wrote:
>> "list_kill" is allocated on stack and it's a list head,
>> it is pointless to call list_del(&kill_list) especially
>> after unregister_netdevice_many().
>
> How pointless exactly ? Explain more please.
>
> I suggest you read various commits adding these list_del()
>
> f87e6f47933e3ebeced9bb12615e830a72cedce4 is a good start.

Interesting thread. Thanks guys!
detailed explanation by Linus:
https://lkml.org/lkml/2011/2/17/267
