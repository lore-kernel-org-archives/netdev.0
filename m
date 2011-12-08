From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: IPv4/IPv6 nf_defrag on/off ?
Date: Thu, 8 Dec 2011 14:44:51 +0100
Message-ID: <201112081444.52166.hans.schillstrom@ericsson.com>
References: <jec613b.4edd5c40857133156bf40cef475e9234@obelix.schillstrom.com> <4ED763EA.50307@trash.net> <201112081012.13065.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Hans Schillstrom <hans@schillstrom.com>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>,
	"pablo@netfilter.org" <pablo@netfilter.org>,
	"jengelh@medozas.de" <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <201112081012.13065.hans.schillstrom@ericsson.com>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello
On Thursday 08 December 2011 10:12:11 Hans Schillstrom wrote:
> Hi 
> While testing HMARK and IPv6 with nf_defrag_ipv6 (and nf_conntrack_ipv6 loaded) I can't see the defrag ?
> 
> From what I can see nf_conntrack_reasm goes into PREROUTING with prio -400
> and HMARK in PREROUTING with prio -150
> 
We are running the external interfaces in LXC containers 
i.e. in a netns and depend on that no defragmentation is done in this stage.
Fragments can arrive on any interface on any blade so...

I had an idea of a sysctl to be able to turn off nf_defrag_ipv{4,6} per namespace
Default is of course on so excisting apps will be happy.
Any objections to that idea ?

-- 
Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
