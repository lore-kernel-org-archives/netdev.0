From: chas williams <chas@cmf.nrl.navy.mil>
Subject: Re: [RFC] add rtnl semaphore to linux-atm
Date: Wed, 01 Oct 2003 09:07:45 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310011307.h91D7jkT004153@ginger.cmf.nrl.navy.mil>
References: <davem@redhat.com>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: Message from "David S. Miller" <davem@redhat.com>
   of "Wed, 01 Oct 2003 05:42:26 PDT." <20031001054226.126cea7b.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In message <20031001054226.126cea7b.davem@redhat.com>,"David S. Miller" writes:
>Although, unless VCC connect can potentially sleep, it might
>be better to keep exporting the rwlock and take it as a reader
>instead of grabbing the rtnl semaphore.

i had initially written it that way but remembered at one point i
was going to use the rtnl semaphore to handle this problem.  any
opinions on what is 'better'?
