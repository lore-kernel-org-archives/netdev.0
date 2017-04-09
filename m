From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH net-next RFC] Generic XDP
Date: Sun, 09 Apr 2017 09:04:07 +0200
Message-ID: <1491721447.4309.2.camel@sipsolutions.net>
References: <20170408.200721.109499285021338999.davem@davemloft.net>
         (sfid-20170409_050731_027484_B256A547) <1491719118.4309.1.camel@sipsolutions.net>
         (sfid-20170409_082543_286603_8F6531E0)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xdp-newbies@vger.kernel.org
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:48976 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751211AbdDIHET (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 9 Apr 2017 03:04:19 -0400
In-Reply-To: <1491719118.4309.1.camel@sipsolutions.net> (sfid-20170409_082543_286603_8F6531E0)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2017-04-09 at 08:25 +0200, Johannes Berg wrote:
> That would also let you use rcu_assign_pointer() which seems like the
> right thing to do here, along with marking the xdp_prog pointer as
> __rcu? That'd also let you use rcu_dereference() instead of
> READ_ONCE() which seems like the better annotation?

Looks like drivers do it exactly this way too though.

What I forgot: I guess we could make drivers use dev->xdp_prog after
this, instead of having their own?

johannes
