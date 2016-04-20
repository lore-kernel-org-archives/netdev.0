From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next 1/4] netlink: fix test alignment in
 nla_align_64bit()
Date: Wed, 20 Apr 2016 12:14:56 +0200
Message-ID: <571756A0.3030200@6wind.com>
References: <20160419.195009.1052027353987244150.davem@davemloft.net>
 <1461142655-5067-1-git-send-email-nicolas.dichtel@6wind.com>
 <1461142655-5067-2-git-send-email-nicolas.dichtel@6wind.com>
 <1461144802.10638.249.camel@edumazet-glaptop3.roam.corp.google.com>
 <57174F8E.6050201@6wind.com>
 <1461146278.10638.253.camel@edumazet-glaptop3.roam.corp.google.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	roopa@cumulusnetworks.com, tgraf@suug.ch, jhs@mojatatu.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:37901 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933524AbcDTKO7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 06:14:59 -0400
Received: by mail-wm0-f46.google.com with SMTP id u206so72999171wme.1
        for <netdev@vger.kernel.org>; Wed, 20 Apr 2016 03:14:58 -0700 (PDT)
In-Reply-To: <1461146278.10638.253.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 20/04/2016 11:57, Eric Dumazet a =C3=A9crit :
> On Wed, 2016-04-20 at 11:44 +0200, Nicolas Dichtel wrote:
>> Le 20/04/2016 11:33, Eric Dumazet a =C3=A9crit :
>> [snip]
>>> How have you tested your patch exactly ?
>> As stated in the cover letter, I didn't test it.
>
>
> You certainly can test this, by tweaking HAVE_EFFICIENT_UNALIGNED_ACC=
ESS
> and adding another assertion in the code.
>
> By testing it you would have caught a real bug, since David incorrect=
ly
> used HAVE_EFFICIENT_UNALIGNED_ACCESS instead of
> CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
>
> ;)
H=C3=A9h=C3=A9, good catch :)
