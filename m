From: Patrick McHardy <kaber@trash.net>
Subject: Re: ip6tables: accept of IPv6 transport esp packages not possible
 - no rule matches
Date: Sun, 02 Jan 2005 22:14:56 +0100
Message-ID: <41D86450.1070904@trash.net>
References: <019064D0423CE6C823CBF476@t1mobil.muc.aerasec.de>
	<5F6ACA5CEF52DBFBF11FBF94@t1mobil.muc.aerasec.de>
	<41CD8B4F.6010402@trash.net>
	<85346B5DA83795C08812E782@worker.muc.bieringer.de>
	<41D7DE3E.2090304@trash.net>
	<E7944B8AE7C7468F39D3C2F8@worker.muc.bieringer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Maillist netdev <netdev@oss.sgi.com>,
	Netfilter development mailing list <netfilter-devel@lists.netfilter.org>,
	USAGI core <usagi-core@linux-ipv6.org>, Harald Welte <laforge@gnumonks.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Peter Bieringer <pb@bieringer.de>
In-Reply-To: <E7944B8AE7C7468F39D3C2F8@worker.muc.bieringer.de>
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

Peter Bieringer wrote:

>>>BTW: how to filter incoming traffic after decryption?
>>>
>>Use tunnel-mode. The decrypted packets will hit PRE_ROUTING
>>and LOCAL_IN again.
>>
>
>Ok, confirmed working in tunnel mode, ping6 packet was counted twice in
>different rules (esp and icmpv6)
>
>But for outgoing ping6 packets, this won't work, packet is only counted
>(and accepted) by the icmpv6 rule, esp rule got no match, also not the
>"all" rule.
>
>Looks like at the moment, outgoing packet is passing netfilter only one
>time, even if encryption is in tunnel mode.
>
That is correct.

>
>By design / bug / missing feature?
>
By design and missing feature :) As I said, patches to fix this for
IPv4 will be submitted this week .. IPv6 will hopefully follow soon.

Regards
Patrick
