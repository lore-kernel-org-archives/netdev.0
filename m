From: Reuben Farrelly <reuben-linux@reub.net>
Subject: Re: Kernel crash in 2.6.0-test9-mm3
Date: Thu, 20 Nov 2003 16:05:27 +1300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <6.0.1.1.0.20031120160110.02412b80@tornado.reub.net>
References: <OF0696EDA9.D66EB77E-ON88256DE3.0009C15A@us.ibm.com>
 <6.0.1.1.0.20031119155347.023f89d0@tornado.reub.net>
 <20031119185157.3edf69c8.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Cc: kumarkr@us.ibm.com, akpm@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031119185157.3edf69c8.davem@redhat.com>
References: <OF0696EDA9.D66EB77E-ON88256DE3.0009C15A@us.ibm.com>
 <6.0.1.1.0.20031119155347.023f89d0@tornado.reub.net>
 <20031119185157.3edf69c8.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Yes - with the patch backed out, the system has been up for 20 hours 
without a crash and nothing has been logged.  I was just holding off a bit 
longer before reporting back in case it just needs a bit more time to 
trigger ;-)

Reuben


At 15:51 20/11/2003, David S. Miller wrote:
>On Wed, 19 Nov 2003 15:58:18 +1300
>Reuben Farrelly <reuben-linux@reub.net> wrote:
>
> > The system is a UP system..
>
>Have you done ask Andrew asked, backing out the atomic_dec_and_test()
>debugging patch to see if all the weird kernel log messages go away
>as a result?
