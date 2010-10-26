From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH] ipv6: addrconf: clear IPv6 addresses and routes when
 losing link
Date: Tue, 26 Oct 2010 11:02:45 -0700
Message-ID: <AANLkTi=Wp83HtQHXG0YEBjmctQYDu9Y4j+O9==_URy_A@mail.gmail.com>
References: <AANLkTi=P80OUBSy3xCt_qOjPGTwNjrtFL1iLJnkc9joq@mail.gmail.com>
 <20101026.104710.232747902.davem@davemloft.net> <AANLkTi=DPaxVLzasA_xs0rPQGBFtfbS7aThx54OT798H@mail.gmail.com>
 <20101026.105524.116376168.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: brian.haley@hp.com, shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:36753 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933225Ab0JZSDK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 14:03:10 -0400
Received: from hpaq7.eem.corp.google.com (hpaq7.eem.corp.google.com [172.25.149.7])
	by smtp-out.google.com with ESMTP id o9QI38HX029228
	for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 11:03:08 -0700
Received: from ywa6 (ywa6.prod.google.com [10.192.1.6])
	by hpaq7.eem.corp.google.com with ESMTP id o9QI31Rm031606
	for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 11:03:07 -0700
Received: by ywa6 with SMTP id 6so3944305ywa.26
        for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 11:03:07 -0700 (PDT)
In-Reply-To: <20101026.105524.116376168.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 26, 2010 at 10:55 AM, David Miller <davem@davemloft.net> wrote:
>> Are there? For wifi you could look at the SSID (though even that is no
>
> I'm saying to check the AP's MAC.

Ah yes, that works better. But for wired? Or do you think it should be
fixed only for wifi?
