From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v3] ipv6: mld: fix add_grhead skb_over_panic for
 devs with large MTUs
Date: Wed, 05 Nov 2014 08:20:13 -0800
Message-ID: <1415204413.13896.5.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1415198530-7126-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, lw1a2.jing@gmail.com, fw@strlen.de,
	hannes@stressinduktion.org, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	David L Stevens <david.stevens@oracle.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:49564 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754864AbaKEQUQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 11:20:16 -0500
Received: by mail-ig0-f172.google.com with SMTP id a13so8980251igq.17
        for <netdev@vger.kernel.org>; Wed, 05 Nov 2014 08:20:15 -0800 (PST)
In-Reply-To: <1415198530-7126-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-11-05 at 15:42 +0100, Daniel Borkmann wrote:
> It has been reported that generating an MLD listener report on
> devices with large MTUs (e.g. 9000) and a high number of IPv6
> addresses can trigger a skb_over_panic():

...

>  v2->v3:
>   - Still had a discussion w/ Hannes and improved the code a bit to
>     make it more clear to read

I am very sorry Daniel, but I found v2 much easier to understand :(

Could you refrain from doing cleanups in this patch,
only provide the very minimal fix ?

No empty lines additions or deletions and stuff like that...

Then, we can cleanup for net-next later if you really want ;)

I know its _very_ tempting to do cleanups, but its very time consuming
to review patches having real stuff done (like bug fixes) and cleanups.

Thanks !
