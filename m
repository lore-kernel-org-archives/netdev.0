From: Lincoln Dale <ltd@cisco.com>
Subject: Re: [PATCH] [RFC] Support for wccp version 1 and 2 in ip_gre.c
Date: Tue, 14 Sep 2004 18:48:20 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <5.1.0.14.2.20040914184652.03e24de0@171.71.163.14>
References: <20040913051706.GB26337@stingr.sgu.ru>
 <20040911194108.GS28258@stingr.sgu.ru>
 <20040912170505.62916147.davem@davemloft.net>
 <20040913051706.GB26337@stingr.sgu.ru> <20040913161912.7dcc809f.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Cc: Paul P Komkoff Jr <i@stingr.net>, i@stingr.net, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040913161912.7dcc809f.davem@davemloft.net>
References: <20040913051706.GB26337@stingr.sgu.ru>
 <20040911194108.GS28258@stingr.sgu.ru>
 <20040912170505.62916147.davem@davemloft.net>
 <20040913051706.GB26337@stingr.sgu.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

At 09:19 AM 14/09/2004, David S. Miller wrote:
> > As you can see, I am applying it unconditionally when fits. For most
> > cases, this will be OK.
> > There can be situations when this is not wanted (for example, when
> > debugging something), so in general, tuning knob will be useful, but
> > I just don't know where to add it, maybe tunnel->parms.i_flags ...
>
>I don't think adding such a knob is necessary, but yes i_flags
>would be the place to do it.
>
>I will apply your patch with the "if(1)" simply removed.

the logic is correct, but it may make sense to call the appropriate 
netfilter hook again with the "unwrapped" GRE packet, as otherwise 
packets-inside-GRE represent a possible security hole where one can inject 
packets externally and bypass firewall rules.


cheers,

lincoln.
