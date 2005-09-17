From: Roman Zippel <zippel@linux-m68k.org>
Subject: Re: [HELP] netfilter Kconfig dependency nightmare
Date: Sat, 17 Sep 2005 13:08:58 +0200 (CEST)
Message-ID: <Pine.LNX.4.61.0509171306290.3743@scrub.home>
References: <20050916021451.3012196c.akpm@osdl.org>
 <20050916191959.GN8413@sunbeam.de.gnumonks.org> <39e6f6c705091617514457eded@mail.gmail.com>
 <20050917012315.GA29841@mandriva.com> <20050917080714.GV8413@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Netfilter Development Mailinglist
	<netfilter-devel@lists.netfilter.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Linux Kernel Mailinglist <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751069AbVIQLJX@vger.kernel.org>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20050917080714.GV8413@sunbeam.de.gnumonks.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Sat, 17 Sep 2005, Harald Welte wrote:

> ip_conntrack == CONFIG_IP_NF_CONNTRACK
> nfnetlink == CONFIG_NETFILTER_NETLINK
> ip_conntrack_netlink == CONFIG_IP_NF_CONNTRACK_NETLINK
> 
> If nfnetlink == N, ip_conntrack can be N or M or Y
> If nfnetlink == M, ip_conntrack can be N or M
> If nfnetlink == Y, ip_conntrack can be Y or M

Where is the requirement for the last one coming from?

> If ip_conntrack == N && nfnetlink == N, ip_conntrack_netlink must be N
> If ip_conntrack == N && nfnetlink == M, ip_conntrack_netlink must be N
> If ip_conntrack == N && nfnetlink == Y, ip_conntrack_netlink must be N
> 
> If ip_conntrack == M && nfnetlink == N, ip_conntrack_netlink must be N 
> If ip_conntrack == M && nfnetlink == M, ip_conntrack_netlink can N or M
> If ip_conntrack == M && nfnetlink == Y, ip_conntrack_netlink can N or M
> 
> if ip_conntrack == Y && nfnetlink == N, ip_conntrack_netlink must be N
> if ip_conntrack == Y && nfnetlink == M, ip_conntrack_netlink can N or M
> if ip_conntrack == Y && nfnetlink == Y, ip_conntrack_netlink can N, M or Y

That looks like a normal ip_conntrack && nfnetlink.

bye, Roman
