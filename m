From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 4189] New: IPv6 link local addresses are not
 assigned correctly on multiple-bonding enviromrnts
Date: Thu, 10 Feb 2005 12:25:23 -0800
Message-ID: <20050210122523.41276d5a.davem@davemloft.net>
References: <20050210002356.500401f7.akpm@osdl.org>
	<20050210.182225.07335127.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com, ikebe.takashi@lab.ntt.co.jp, akpm@osdl.org,
        ctindel@users.sourceforge.net, fubar@us.ibm.com,
        bonding-devel@lists.sourceforge.net
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20050210.182225.07335127.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 10 Feb 2005 18:22:25 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> Ethernet devices is not allowed to change its MAC during it is up.

This is not true.

All ethernet drivers try to support this, and just about all do.
This is what dev->set_mac_address() driver routine implements.

I guess this causes problems for ipv6 local addresses, it
will need to catch some callback to handle these events and
thus adjust the local address properly.

This is the real bug in my opinion, ipv4 handles this situation
just fine.
