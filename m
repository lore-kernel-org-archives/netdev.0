From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [Bonding-devel] Re: [Bugme-new] [Bug 4189] New: IPv6 link local
 addresses are not assigned correctly on multiple-bonding enviromrnts
Date: Thu, 10 Feb 2005 12:27:45 -0800
Message-ID: <20050210122745.16ca7cb3.davem@davemloft.net>
References: <20050210.182225.07335127.yoshfuji@linux-ipv6.org>
	<200502101817.j1AIH6p7000602@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com, ikebe.takashi@lab.ntt.co.jp,
        akpm@osdl.org, ctindel@users.sourceforge.net,
        bonding-devel@lists.sourceforge.net
To: Jay Vosburgh <fubar@us.ibm.com>
In-Reply-To: <200502101817.j1AIH6p7000602@death.nxdomain.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 10 Feb 2005 10:17:06 -0800
Jay Vosburgh <fubar@us.ibm.com> wrote:

> 	The model used by the bridge device is probably a better way to
> go, particularly given that IPv6 link local addresses are created at
> "ifconfig up" time.

IPv6 should catch an event when MAC addresses change, to reassign
to correct link local address.  I don't think the bonding driver
needs to change at all.

IPv6 needs to fix this issue, regardless of bonding.  It is perfectly
legal to change MAC addresses while a link is still up.
