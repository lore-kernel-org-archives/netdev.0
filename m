From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 00/10]: Netfilter IPsec support
Date: Fri, 11 Nov 2005 04:18:52 +0100
Message-ID: <43740D9C.80003@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Kernel Netdev Mailing List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
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

This is the latest set patches for netfilter IPsec support.
The use of netif_rx for the innermost SA if it used transport
mode has been replaced by explicit NF_HOOK calls in
xfrm{4,6}_input.c.

[NETFILTER]: Remove okfn usage in ip_vs_core.c
[NETFILTER]: Defer fragmentation in ip_output when connection tracking 
is used
[IPV4]: Replace dst_output by ip_dst_output
[IPV6]: Replace dst_output by ip6_dst_output
[IPV4/6]: Netfilter IPsec output hooks
[IPV4/6]: Make input netfilter IPsec processing symetrical to output
[NETFILTER]: Fix xfrm lookup in ip_route_me_harder
[NETFILTER]: Use conntrack information to determine if packet was NATed
[NETFILTER]: Redo policy lookups after NAT when neccessary
[NETFILTER]: Handle NAT in IPsec policy checks
