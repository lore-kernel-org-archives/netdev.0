From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 4189] New: IPv6 link local addresses are not
 assigned correctly on multiple-bonding enviromrnts
Date: Thu, 10 Feb 2005 17:06:31 -0800
Message-ID: <20050210170631.65d33139.davem@davemloft.net>
References: <20050210002356.500401f7.akpm@osdl.org>
	<20050210.182225.07335127.yoshfuji@linux-ipv6.org>
	<20050210122523.41276d5a.davem@davemloft.net>
	<20050211.092916.50162307.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com, ikebe.takashi@lab.ntt.co.jp, akpm@osdl.org,
        ctindel@users.sourceforge.net, fubar@us.ibm.com,
        bonding-devel@lists.sourceforge.net
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20050211.092916.50162307.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 11 Feb 2005 09:29:16 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> Okay, I'll try to solve it:
> 1) catch NETDEV_CHANGEADDR
> 2) (try to) add new link-local address and deprecate old one.
> 3) (when DAD finishes) RS will be sent.

Sounds perfect.
