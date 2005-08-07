From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] add new nfnetlink_log subsystem
Date: Sun, 7 Aug 2005 13:20:39 +0200
Message-ID: <20050807112039.GF10481@postel.suug.ch>
References: <20050730103005.GB6620@rama.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Harald Welte <laforge@gnumonks.org>, David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Content-Disposition: inline
In-Reply-To: <20050730103005.GB6620@rama.de.gnumonks.org>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

* Harald Welte <20050730103005.GB6620@rama.de.gnumonks.org> 2005-07-30 12:30
> This (long-awaited) patch adds the generic nfnetlink-based userspace
> logging.  nfnetlink_log can be used for any protocol family, and
> supports upt to 65535 logging groups (that could go to separate logging
> daemons, e.g.).

Same very minor issues as nfnetlink regarding some of the
new netlink message construction policies. I'll "fix" them
during the conversion to the generic netlink attributes.
