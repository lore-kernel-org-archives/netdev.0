From: David Coulson <david@davidcoulson.net>
Subject: Re: skb_checksum_help
Date: Mon, 24 Jan 2005 10:27:47 -0500
Message-ID: <41F513F3.7000708@davidcoulson.net>
References: <20050124005348.GL23931@postel.suug.ch> <E1Cst4o-0007bD-00@gondolin.me.apana.org.au> <20050123202715.281ac87c.davem@davemloft.net> <20050124121610.GP23931@postel.suug.ch> <41F50B6C.6010107@davidcoulson.net> <20050124151510.GV23931@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Herbert Xu <herbert@gondor.apana.org.au>, kaber@trash.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050124151510.GV23931@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:

> After inspecting your iptables rule set I think it is a general UDP DNAT
> problem under some circumstances. Some defragmentation weirdness in
> prerouting might be invovled. It would definitely help to have a dump
> of a complete ip fragments sequence causing this bug but I can't tell
> what exactly is the cause just now so yes it might be a good idea to
> limit the dump to the above subnet and hope the dodgy traffic comes
> from the same subnet again.

cr1:~# tcpdump -nxxli vlan102 net 211.32.117.0/24 and port 53 > tcpdump.txt

I assume that 'xx' is sufficient to dump all of the packet/link 
information we need?

David

-- 
David J. Coulson
email: david@davidcoulson.net
web: http://www.davidcoulson.net/
phone: (216) 920-3100 / (216) 258-4942
