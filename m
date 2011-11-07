From: Ajith Adapa <adapa.ajith@gmail.com>
Subject: Re: Regarding Routing table in Linux kernel
Date: Mon, 7 Nov 2011 09:52:21 +0530
Message-ID: <CADAe=+KTYAGT4N9R2eTHstbBP89PJPD57jYNp6diGocnoYkaFw@mail.gmail.com>
References: <CADAe=+J-yjh-GujhVY58qKirGNANQ6fUnPdzvoQzQSxMDv7VPw@mail.gmail.com>
 <1320601372.6506.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:38755 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750705Ab1KGEWx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Nov 2011 23:22:53 -0500
Received: by faao14 with SMTP id o14so4722999faa.19
        for <netdev@vger.kernel.org>; Sun, 06 Nov 2011 20:22:52 -0800 (PST)
In-Reply-To: <1320601372.6506.11.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for the reply

>> 1. Why does the linux kernel use hashing table for storing routing
>> entries when there is patricia trie or radix tree which is more faster
>> than Hash table ?
>
> I think you are mistaken. Routes are stored in a trie in recent kernels.
>
> And route cache is scheduled to be removed at some point.
>
> In normal situation, one hash lookup is the faster way to find a random
> item, its a single memory cache line cost.

I will check it with the latest kernel. Actually I am just checking in
a 2.6.18 kernel.

>> 2. Is there any way we can test the performance of an routing
>> algorithm before deploying in a real time scenario to check its
>> performance ? I would like to test one of my implementations to check
>> if there are any performance gains or not ?
>
> Sorry there is no general answer. It all depends on your needs.

Hmm .. Seems there is no simple way for it other than trying out in
real time scenario :(
