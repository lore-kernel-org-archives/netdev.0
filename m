From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next 1/4] netlink: fix test alignment in
 nla_align_64bit()
Date: Wed, 20 Apr 2016 11:44:46 +0200
Message-ID: <57174F8E.6050201@6wind.com>
References: <20160419.195009.1052027353987244150.davem@davemloft.net>
 <1461142655-5067-1-git-send-email-nicolas.dichtel@6wind.com>
 <1461142655-5067-2-git-send-email-nicolas.dichtel@6wind.com>
 <1461144802.10638.249.camel@edumazet-glaptop3.roam.corp.google.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	roopa@cumulusnetworks.com, tgraf@suug.ch, jhs@mojatatu.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:36639 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932923AbcDTJot (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 05:44:49 -0400
Received: by mail-wm0-f45.google.com with SMTP id v188so195693677wme.1
        for <netdev@vger.kernel.org>; Wed, 20 Apr 2016 02:44:49 -0700 (PDT)
In-Reply-To: <1461144802.10638.249.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 20/04/2016 11:33, Eric Dumazet a =C3=A9crit :
[snip]
> How have you tested your patch exactly ?
As stated in the cover letter, I didn't test it.

>
> I guess David should have copied his original comment here.
>
> -        * The nlattr header is 4 bytes in size, that's why we test
> -        * if the skb->data _is_ aligned.  This NOP attribute, plus
> -        * nlattr header for IFLA_STATS64, will make nla_data() 8-byt=
e
> -        * aligned.
>
>
I knew I was missing something, thanks for the explanation.

All other patches of this series need to be updated, I will do it if th=
ere is
no other comment.
