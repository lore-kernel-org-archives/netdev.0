From: kuznet@ms2.inr.ac.ru
Subject: Re: [PATCH] Networking: send-to-self [link to non-broken patch this
Date: Fri, 27 Sep 2002 19:01:53 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200209271501.TAA21079@sex.inr.ac.ru>
References: <3D93FBA6.6080905@candelatech.com>
Mime-Version: 1.0
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: greearb@candelatech.com (Ben Greear)
In-Reply-To: <3D93FBA6.6080905@candelatech.com> from "Ben Greear" at Sep 26, 2 11:33:10 pm
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> I have a question though:  If this method is ever called to send an RST,
> will it work?

Work for what? This method is used when you have no socket in the system
matching to this skb. :-)

> What about this part, do you think it is not needed either?  It appeared
> to me that w/out this, the sending socket and the receiving socket
...
> sending one, unfortunately).

No, this is impossible. addrs/ports identity identifies socket unambiguously.

But even this does not matter, your patch is noop by much simpler pure
"syntactical" reason, it copies req->bound_dev_if from listening socket.
And after this the check in lookup req degenerates to TRUE __identitically__.
 :-)

Alexey
