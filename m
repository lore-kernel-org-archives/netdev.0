From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: HELP for dccp implementation.
Date: Wed, 1 Sep 2004 23:48:05 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040902024805.GA23844@conectiva.com.br>
References: <412CC269.8080907@rus.uni-stuttgart.de> <1093454747.1034.85.camel@jzny.localdomain> <4135A32A.4030901@rus.uni-stuttgart.de> <20040901133709.3637d63d.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Zhikui Chen <zhikui.chen@rus.uni-stuttgart.de>, hadi@cyberus.ca,
        dccp@ietf.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040901133709.3637d63d.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Wed, Sep 01, 2004 at 01:37:09PM -0700, David S. Miller escreveu:
> On Wed, 01 Sep 2004 12:23:38 +0200
> Zhikui Chen <zhikui.chen@rus.uni-stuttgart.de> wrote:
> 
> > If I assign a value such as 0x ee9fbc00 to sk in dccp_rcv (before lookup 
> > calling), and comment lookkup calling, I get a error report from 
> > bh_lock_sock(sk) calling inside dccp_rcv, which error report is  
> > spin_is_locked on uninitialized spinlock ee9fbc00, and spin_lock 
> > (<NULL>:ee9fbc00) already locked by <NULL>/73.
> > 
> > Do you know its reason? Thanks,
> 
> Zhikui, are you working together with Arnaldo using his
> code base, like we suggested to you?  Or are you working
> still on your own code?

Dave, I've been quite busy lately with some other projects and haven't
been able to colaborate with Zhikui, I hope to change this situation
soon.

Regards,

                        - Arnaldo
