From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [Bonding-devel] Re: [Bugme-new] [Bug 4189] New: IPv6 link local
 addresses are not assigned correctly on multiple-bonding enviromrnts
Date: Thu, 10 Feb 2005 13:26:24 -0800
Message-ID: <420BD180.2040605@hp.com>
References: <20050210.182225.07335127.yoshfuji@linux-ipv6.org>	<200502101817.j1AIH6p7000602@death.nxdomain.ibm.com> <20050210122745.16ca7cb3.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>, yoshfuji@linux-ipv6.org,
        netdev@oss.sgi.com, ikebe.takashi@lab.ntt.co.jp, akpm@osdl.org,
        ctindel@users.sourceforge.net, bonding-devel@lists.sourceforge.net
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050210122745.16ca7cb3.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 >IPv6 should catch an event when MAC addresses change, to reassign
> to correct link local address.  I don't think the bonding driver
> needs to change at all.
> 
> IPv6 needs to fix this issue, regardless of bonding.  It is perfectly
> legal to change MAC addresses while a link is still up.

This may seem a silly question, but what happens to existing TCP connections 
when the IPv6 link local address changes?

rick jones
