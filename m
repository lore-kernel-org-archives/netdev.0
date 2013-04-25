From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next PATCH 2/4] net: increase frag hash size
Date: Thu, 25 Apr 2013 16:13:33 +0400
Message-ID: <51791DED.2080803@cogentembedded.com>
References: <20130424154624.16883.40974.stgit@dragon>  <20130424154822.16883.93014.stgit@dragon>  <51785827.1000007@cogentembedded.com> <1366884795.26911.510.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:51143 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756639Ab3DYMOt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 08:14:49 -0400
Received: by mail-la0-f45.google.com with SMTP id em20so1399685lab.4
        for <netdev@vger.kernel.org>; Thu, 25 Apr 2013 05:14:47 -0700 (PDT)
In-Reply-To: <1366884795.26911.510.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 25-04-2013 14:13, Jesper Dangaard Brouer wrote:

>>> Increase fragmentation hash bucket size to 1024 from old 64 elems.

>>> After we increased the frag mem limits (in commit v3.8-rc3-503-gc2a9366)

>>      This is not a commit ID, commit ID is SHA1 key alone. And you should also
>> specify that commit's summary line with it, in parens.

> Did you know that you can use the string "v3.8-rc3-503-gc2a9366" like:
>   git show v3.8-rc3-503-gc2a9366

    No, I didn't. I only know such string is a result of the command 'git 
describe' (if I don't mistake).

> That's why I like this kind of commit ID better, as it also tell the
> reader what approx version this patch were in.

   Understood. Everybody else is using SHA1 though for which gitweb certainly 
could generate a coimmit link if it encountered SHA1 in the changelog. Now, 
with the switch of kernel.org to cgit though, this ability seems to be gone.
That's why (in part) I don't think using cgit was such a good idea... I want 
the old gitweb back!

> --JEsper

WBR, Sergei
