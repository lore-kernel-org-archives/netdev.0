From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] ipv4: early demux should be aware of fragments
Date: Fri, 29 Jan 2016 07:22:06 -0800
Message-ID: <1454080926.7627.49.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAPWQB7GgKU8TC6RQNkkZppNrH64ufOH50g2VXHp8D8WC7_gh_g@mail.gmail.com>
	 <1453787905.11327.11.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1453856382.11327.49.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20160127.170203.701586924097928864.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: joe@ovn.org, netdev@vger.kernel.org, fw@strlen.de,
	hannes@stressinduktion.org, pshelar@ovn.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34941 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752937AbcA2PWI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 10:22:08 -0500
Received: by mail-pf0-f194.google.com with SMTP id 66so3481393pfe.2
        for <netdev@vger.kernel.org>; Fri, 29 Jan 2016 07:22:08 -0800 (PST)
In-Reply-To: <20160127.170203.701586924097928864.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-01-27 at 17:02 -0500, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 26 Jan 2016 16:59:42 -0800
> 
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > We should not assume a valid protocol header is present,
> > as this is not the case for IPv4 fragments.
> > 
> > Lets avoid extra cache line misses and potential bugs
> > if we actually find a socket and incorrectly uses its dst.
> > 
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> 
> Applied, thanks.

David, I do not see this patch in net tree ?

Thanks !
