From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: netfilter6: ICMPv6 type 143 doesn't match
Date: Thu, 5 May 2005 15:26:27 -0700
Message-ID: <OF647D617E.F01230B8-ON88256FF8.007AF1C9-88256FF8.007B457C@us.ibm.com>
References: <427A79C0.4020103@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: usagi-users@linux-ipv6.org, netdev@oss.sgi.com,
	Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>,
	netfilter-devel@lists.netfilter.org, laforge@gnumonks.org,
	pb@bieringer.de, netdev-bounce@oss.sgi.com
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
In-Reply-To: <427A79C0.4020103@trash.net>
To: Patrick McHardy <kaber@trash.net>
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

I'll look at it in more detail and let you know if I see any problems,
but I wouldn't call it "igmpv6", which doesn't exist. "MLD" is the
equivalent in IPv6. There certainly are existing references to
"igmp6" in the Linux code-- that just isn't the name of the protocol. :-)

suggest: change to mld_dev_queue_xmit().

                                        +-DLS
