From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [2.6 PATCH] ipvs - remove some unused fields from the protocols
Date: Tue, 07 Oct 2003 20:14:25 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031007134931.CA9662C7A8@lists.samba.org>
References: <Pine.LNX.4.44.0310070104470.6107-100000@u.domain.uli>
Cc: "David S. Miller" <davem@redhat.com>, Wensong Zhang <wensong@linux-vs.org>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-reply-to: Your message of "Tue, 07 Oct 2003 01:16:36 +0300."
             <Pine.LNX.4.44.0310070104470.6107-100000@u.domain.uli>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In message <Pine.LNX.4.44.0310070104470.6107-100000@u.domain.uli> you write:
> 
> 	Hello,
> 
> 	The promised removal of some unused fields. For inclusion after 
> comments from Rusty. Rusty, it seems we can not convert the transmitters 
> to NF_STOLEN, ip_vs_null_xmit returns NF_ACCEPT.

Ah that's right.  I hit that as I was halfway through changing, and
reverted.  Sorry.

Leaving the comment there and adding one in ip_vs_null_xmit on why
breaking the rule in that case is OK is the right approach, I think.

Patch looks good!

Thanks,
Rusty.
--
  Anyone who quotes me in their sig is an idiot. -- Rusty Russell.
