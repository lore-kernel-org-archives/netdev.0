From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] LSM networking: skb hooks for 2.5.42 (2/7)
Date: Tue, 15 Oct 2002 10:40:14 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021015.104014.34145167.davem@redhat.com>
References: <Mutt.LNX.4.44.0210160027110.27676-100000@blackbird.intercode.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, linux-security-module@wirex.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jmorris@intercode.com.au
In-Reply-To: <Mutt.LNX.4.44.0210160027110.27676-100000@blackbird.intercode.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


There is no way in hell that you are going to
add a function call for every time we set the
socket owner of a SKB.

That is a critical path and it happens millions upon
millions of times a second on a busy server.  Performance
will be penalized by changes like this.

I want all this junk #ifdef'd if it is necessary, in particular
the new member added to sk_buff et al.  There is no way this stuff
is going to happen in the default build, at least not in my networking
tree :-)
