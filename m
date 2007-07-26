From: Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>
Subject: Re: [PATCH][v2] Netfilter Kconfig: Expose IPv4/6 connection
 tracking options by selecting NF_CONNTRACK_ENABLED
Date: Thu, 26 Jul 2007 10:18:22 +0900 (JST)
Message-ID: <200707260118.l6Q1INGw004789@toshiba.co.jp>
References: <200707251802.22200.a1426z@gawab.com> <46A7EECD.9070801@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, a1426z@gawab.com,
	netfilter-devel@lists.netfilter.org, sam@ravnborg.org
To: kaber@trash.net
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
In-Reply-To: <46A7EECD.9070801@trash.net>
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

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 26 Jul 2007 02:46:05 +0200

> [Removed a few CCs]
> 
> Al Boldi wrote:
> > Make NF_CONNTRACK_IPV4 and NF_CONNTRACK_IPV6 select NF_CONNTRACK_ENABLED.
> 
> 
> One thought that occured to me after the last of many false bugreports
> that were actually caused by failure to configure the new options
> properly. Most people know they want NF_CONNTRACK (and its selected by
> default with old configs), what they're missing is that they now also
> need to select IPv4 connection tracking. So what would really make sense
> is to make NF_CONNTRACK_IPV4 default to "m" (and really *everyone*
> using conntrack wants this). But with your proposed change this would
> default to selecting NF_CONNTRACK by default, which I'm not so sure
> is a good idea. So I'm leaning towards just using "m" as default for
> IPv4 conntrack to save people trouble and myself some bugreports, but
> I also like your simplification ...
> 
> Maybe we can do something to have the NF_CONNTRACK_ENABLED option select
> NF_CONNTRACK_IPV4 (which really is what we actually want) and combine
> that with automatic selection of NF_CONNTRACK? I believe the only case
> with negative impact would be people that currently use only IPv6
> connection tracking, which is most likely nobody.

I agree. I've not heard trouble with NF_CONNTRACK_IPV6. I think that is
because it is purely new feature.

BTW, it's too late to restore IP_NF_CONNTRACK in stable and current tree
for a while ?

-- Yasuyuki Kozakai
