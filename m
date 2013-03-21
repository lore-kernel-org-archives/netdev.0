From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/2] netlink: Diag core and basic socket info dumping
Date: Thu, 21 Mar 2013 14:41:20 +0000
Message-ID: <20130321144120.GE9046@casper.infradead.org>
References: <1363857669-19990-1-git-send-email-avagin@openvz.org>
 <1363857669-19990-3-git-send-email-avagin@openvz.org>
 <20130321125230.GB9046@casper.infradead.org>
 <20130321143119.GA14763@paralelels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrey Vagin <avagin@openvz.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Pavel Emelyanov <xemul@parallels.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Gao feng <gaofeng@cn.fujitsu.com>
To: Andrew Vagin <avagin@parallels.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130321143119.GA14763@paralelels.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/21/13 at 06:31pm, Andrew Vagin wrote:
> The code in ss looks like you described:
>         struct rtattr *tb[UNIX_DIAG_MAX+1];
> ...
>         parse_rtattr(tb, UNIX_DIAG_MAX, (struct rtattr*)(r+1),
>                      nlh->nlmsg_len - NLMSG_LENGTH(sizeof(*r)));
> 
> 
>         struct rtattr *tb[NETLINK_DIAG_MAX+1];
> ...
>         parse_rtattr(tb, NETLINK_DIAG_MAX, (struct rtattr*)(r+1),
>                      nlh->nlmsg_len - NLMSG_LENGTH(sizeof(*r)))
> 
> I think I should only update headers... Or I don't understand something.

Right, fixing the headers will resolve the issue.
