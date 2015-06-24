From: ratheesh kannoth <ratheesh.ksz@gmail.com>
Subject: Re: sock_hold and sock_put
Date: Wed, 24 Jun 2015 19:44:49 +0530
Message-ID: <CAGZFCEFQju581PDF3QpyX-s8vvdxPrZTwS85CP3rTu4wUfEHBg@mail.gmail.com>
References: <CAGZFCEHHXbnsSoBaTUdxqwoQ75hN5BTBXJMEXp0dkwQbFSEkRw@mail.gmail.com>
	<1435150000.4110.7.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	linux-newbie <linux-newbie@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:32808 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753143AbbFXOOu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2015 10:14:50 -0400
In-Reply-To: <1435150000.4110.7.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 24, 2015 at 6:16 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> You misunderstood the comment.
>
> Comment only stated that sock_hold() must be used in contexts where
> caller owns a reference (and will eventually release it later with
> sock_put().
>
> There is nothing about having a lock here.

Thanks. I think, i did not put the question right.

I understood the comment perfectly. Suppose i need to use the
sock_hold in some callbacks ( say netdev_notifier chain callback)
function. How can i gurantee race won't happen at the point where i
call sock_hold().
 If i put the question  in another way - say kernel is doing a
sock_put() on a socket, and at the same time  the   netdev_callback
function( that i implemented ) is called on another core ( in smp
machine ). and the  callback is  holding (sock_hold()) on the same
sock.

Thanks,
Ratheesh
