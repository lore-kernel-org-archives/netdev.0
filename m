From: Thomas Graf <tgraf@suug.ch>
Subject: Re: skb_checksum_help
Date: Mon, 24 Jan 2005 16:15:10 +0100
Message-ID: <20050124151510.GV23931@postel.suug.ch>
References: <20050124005348.GL23931@postel.suug.ch> <E1Cst4o-0007bD-00@gondolin.me.apana.org.au> <20050123202715.281ac87c.davem@davemloft.net> <20050124121610.GP23931@postel.suug.ch> <41F50B6C.6010107@davidcoulson.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Herbert Xu <herbert@gondor.apana.org.au>, kaber@trash.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Coulson <david@davidcoulson.net>
Content-Disposition: inline
In-Reply-To: <41F50B6C.6010107@davidcoulson.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* David Coulson <41F50B6C.6010107@davidcoulson.net> 2005-01-24 09:51
> Thomas Graf wrote:
> >Yes, this might clear things up.
> 
> 10.1.1.5 is a production NS, so there is >500kbit/sec of DNS traffic to 
> the box. Do you want me to restrict tcpdump to the /24 we were seeing 
> traffic from which broke the kernel, or dump everything and send the 
> part from around when the kernel fails?

After inspecting your iptables rule set I think it is a general UDP DNAT
problem under some circumstances. Some defragmentation weirdness in
prerouting might be invovled. It would definitely help to have a dump
of a complete ip fragments sequence causing this bug but I can't tell
what exactly is the cause just now so yes it might be a good idea to
limit the dump to the above subnet and hope the dodgy traffic comes
from the same subnet again.
