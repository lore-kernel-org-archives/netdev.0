From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next] tcp: fix ipv4 mapped request socks
Date: Thu, 26 Mar 2015 17:37:55 +0100
Message-ID: <551435E3.5060101@6wind.com>
References: <1427258756.25985.104.camel@edumazet-glaptop2.roam.corp.google.com>	 <20150325.005738.199321600853824869.davem@davemloft.net>	 <1427260862.25985.105.camel@edumazet-glaptop2.roam.corp.google.com>	 <20150325054837.GA790@localhost.westell.com> <1427302121.25985.117.camel@edumazet-glaptop2.roam.corp.google.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:35489 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752546AbbCZQh6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 12:37:58 -0400
Received: by wgdm6 with SMTP id m6so70837365wgd.2
        for <netdev@vger.kernel.org>; Thu, 26 Mar 2015 09:37:57 -0700 (PDT)
In-Reply-To: <1427302121.25985.117.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 25/03/2015 17:48, Eric Dumazet a =C3=A9crit :
> On Tue, 2015-03-24 at 22:48 -0700, Alexei Starovoitov wrote:
>
>> btw, the following time saving steps were useful to me:
>>
>> 1. add to your ~/.gitconfig
>> [core]
>>          abbrev =3D 12
>> [pretty]
>>          fixes =3D Fixes: %h (\"%s\")
>>
>> 2. when bad commit is found do:
>> $ git log -1 --pretty=3Dfixes 3f66b083a5b7f1a63540c24df3679c24f
>>
>> which will print:
>>
>> Fixes: 3f66b083a5b7 ("inet: introduce ireq_family")
>>
>> 3. copy-paste that line into your patch
>
> Nice trick ! You should capture it somehow in Documentation/... !
It's already done here ;-)
http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/Doc=
umentation/SubmittingPatches#n193
