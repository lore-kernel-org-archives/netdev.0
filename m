From: Reuben Farrelly <reuben-linux@reub.net>
Subject: Re: Kernel crash in 2.6.0-test9-mm3
Date: Thu, 20 Nov 2003 20:30:31 +1300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <6.0.1.1.2.20031120202518.01b53738@tornado.reub.net>
References: <OF0696EDA9.D66EB77E-ON88256DE3.0009C15A@us.ibm.com>
 <6.0.1.1.0.20031119155347.023f89d0@tornado.reub.net>
 <20031119185157.3edf69c8.davem@redhat.com>
 <6.0.1.1.0.20031120160110.02412b80@tornado.reub.net>
 <20031119190258.4d926957.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Cc: kumarkr@us.ibm.com, akpm@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031119190258.4d926957.davem@redhat.com>
References: <OF0696EDA9.D66EB77E-ON88256DE3.0009C15A@us.ibm.com>
 <6.0.1.1.0.20031119155347.023f89d0@tornado.reub.net>
 <20031119185157.3edf69c8.davem@redhat.com>
 <6.0.1.1.0.20031120160110.02412b80@tornado.reub.net>
 <20031119190258.4d926957.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ok I'll take this up with jakub@redhat, the gcc package maintainer at Redhat.

What is interesting (or scary) is that the version of gcc that I'm using 
(3.3.2-2) is only one rebuild out from the one shipped in Fedora Core 1 
(3.3.2-1), so I may not be the last person to hit this problem..

Reuben


At 04:02 p.m. 20/11/2003, David S. Miller wrote:
>On Thu, 20 Nov 2003 16:05:27 +1300
>Reuben Farrelly <reuben-linux@reub.net> wrote:
>
> > Yes - with the patch backed out, the system has been up for 20 hours
> > without a crash and nothing has been logged.  I was just holding off a bit
> > longer before reporting back in case it just needs a bit more time to
> > trigger ;-)
>
>Thanks a lot for this feedback.
>
>I really think gcc-3.x you're using is miscompiling some parts of
>the kernel with the patch applied.  Someone should look at the
>x86 output assembler for things like the atomic_dec_and_test() call
>in net/core/skbuff.c:kfree_skbmem()
