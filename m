From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH] ipv6: addrconf: clear IPv6 addresses and routes when
 losing link
Date: Wed, 27 Oct 2010 09:01:25 -0700
Message-ID: <AANLkTikhhsEu7zzYpEH-Dby_Ke77iSo0z1wu2t-xU+Jc@mail.gmail.com>
References: <AANLkTikFnwM9Ks6h1Jb0+pNW6rkmcKnbVNzKdXUqPnHU@mail.gmail.com>
 <20101026.112321.258116003.davem@davemloft.net> <AANLkTik2Q=fF9j6eiBQx33e2JU7EG3Sc5hnXyDH24+mt@mail.gmail.com>
 <20101027.085115.104074771.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: brian.haley@hp.com, shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:55141 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752739Ab0J0QBt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 12:01:49 -0400
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id o9RG1lDM007756
	for <netdev@vger.kernel.org>; Wed, 27 Oct 2010 09:01:47 -0700
Received: from gyh20 (gyh20.prod.google.com [10.243.50.212])
	by wpaz33.hot.corp.google.com with ESMTP id o9RG1X0O016406
	for <netdev@vger.kernel.org>; Wed, 27 Oct 2010 09:01:46 -0700
Received: by gyh20 with SMTP id 20so550965gyh.14
        for <netdev@vger.kernel.org>; Wed, 27 Oct 2010 09:01:46 -0700 (PDT)
In-Reply-To: <20101027.085115.104074771.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 27, 2010 at 8:51 AM, David Miller <davem@davemloft.net> wrote:
>> As the patch stands, they don't. Only autoconfigured addresses will be
>> cleared, because addrconf_ifdown() does not remove any addresses that
>> are permanent (unless they are link-local, in which case they are
>> recreated as soon as link comes back).
>
> Ok, and that brings us back to the issue of losing a TCP connection
> over a link-local et al. address during a minor link flap.

TCP connections don't go away when the address they are using goes
away. They go away if their address goes away forever. As mentioned
above in the thread, I did test this :)
