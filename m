From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] TCP congestion schedulers
Date: 18 Mar 2005 08:43:04 -0500
Message-ID: <1111153298.1146.35.camel@jzny.localdomain>
References: <421CF5E5.1060606@ev-en.org> <421D30FA.1060900@ev-en.org>
	 <20050225120814.5fa77b13@dxpl.pdx.osdl.net>
	 <20050309210442.3e9786a6.davem@davemloft.net> <4230288F.1030202@ev-en.org>
	 <20050310182629.1eab09ec.davem@davemloft.net>
	 <20050311120054.4bbf675a@dxpl.pdx.osdl.net>
	 <20050311201011.360c00da.davem@davemloft.net>
	 <20050314151726.532af90d@dxpl.pdx.osdl.net>
	 <20050317201231.6d575e0b.davem@davemloft.net>
	 <39e6f6c705031804531c2c557f@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Stephen Hemminger <shemminger@osdl.org>, baruch@ev-en.org,
        netdev@oss.sgi.com
To: acme@conectiva.com.br
In-Reply-To: <39e6f6c705031804531c2c557f@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-03-18 at 07:53, Arnaldo Carvalho de Melo wrote:

> > I'm also not so religious anymore about retaining the existing
> > sysctl functionality to enable/disable ca algs.
> 
> I haven't looked over this patch completely, so I may well be saying something
> stupid, but if possible, please don't use the tcp/TCP prefix where you
> think this
> code can be used by other inet transport protocols, such as DCCP. 

Yes, that would be really nice. 

Also heres another thought: if we can have multiple sockets, destined to
the same receiver, to share the same congestion state. This is motivated
from the CM idea the MIT folks were preaching a few years ago - look at
RFC 3124 and the MIT website which had some crude linux code back then
as well as tons of papers. I think
that scheme may need to hook up to tc to work well.

cheers,
jamal
