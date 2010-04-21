From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next-2.6] rps: consistent rxhash
Date: Wed, 21 Apr 2010 12:12:41 -0700
Message-ID: <g2m65634d661004211212t13714cccyd27936c520515684@mail.gmail.com>
References: <1271769404.7895.10.camel@edumazet-laptop>
	 <4BCDB425.9050007@lastsummer.de>
	 <1271775421.7895.19.camel@edumazet-laptop>
	 <20100420.144106.118596093.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: eric.dumazet@gmail.com, franco@lastsummer.de, xiaosuo@gmail.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:54285 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754188Ab0DUTMq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 15:12:46 -0400
Received: from hpaq7.eem.corp.google.com (hpaq7.eem.corp.google.com [10.3.21.7])
	by smtp-out.google.com with ESMTP id o3LJCidi012844
	for <netdev@vger.kernel.org>; Wed, 21 Apr 2010 21:12:44 +0200
Received: from pwj2 (pwj2.prod.google.com [10.241.219.66])
	by hpaq7.eem.corp.google.com with ESMTP id o3LJCg2B011452
	for <netdev@vger.kernel.org>; Wed, 21 Apr 2010 21:12:43 +0200
Received: by pwj2 with SMTP id 2so5098495pwj.3
        for <netdev@vger.kernel.org>; Wed, 21 Apr 2010 12:12:41 -0700 (PDT)
In-Reply-To: <20100420.144106.118596093.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 20, 2010 at 2:41 PM, David Miller <davem@davemloft.net> wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 20 Apr 2010 16:57:01 +0200
>
>> I know many applications using TCP on loopback, they are real :)
>
> This is all true and I support your hashing patch and all of that.
>
> But if we really want TCP over loopback to go fast, there are much
> better ways to do this.
>
> Eric, do you remember that "TCP friends" rough patch I sent you last
> year that essentailly made TCP sockets over loopback behave like
> AF_UNIX ones and just queue the SKBs directly to the destination
> socket without doing any protocol work?
>

This is sounds very interesting!  Could you post a patch? :-)

> If we ever got that working, tbench performance would become
> impressive :)
>
