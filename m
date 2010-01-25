From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: [PATCH v2]IP: Send  an ICMP "Fragment Reassembly Timeout" message
 when enabling connection track
Date: Mon, 25 Jan 2010 16:18:29 +0800
Message-ID: <4B5D53D5.9080803@cn.fujitsu.com>
References: <4B57AC35.8070902@cn.fujitsu.com> <4B5844F2.30104@trash.net> <4B590BE3.40509@cn.fujitsu.com> <4B599084.1060406@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4B599084.1060406@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote, at 01/22/2010 07:48 PM:
> Looks good to me. Would you mind adding a similar change to IPv6
> (net/ipv6/netfilter/nf_conntrack_reasm.c)?

Sorry to reply to you so late. 
I'm grade to send a patch to change IPv6 conntrack.

I also find that reassembly queues of IPv6 conntrack are broken 
when be initialed by ip6_frag_init(). After testing, I will send all patches.

-- 
Best Regards
-----
Shan Wei




