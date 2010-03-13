From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [RFC PATCH net-next 1/7 v2]IPv6:netfilter: defrag: Handle sysctls
 about IPv6 conntrack defragment per-netns
Date: Sat, 13 Mar 2010 22:58:54 +0900
Message-ID: <4B9B9A1E.8080102@linux-ipv6.org>
References: <4B88BE39.6050307@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org, yoshfuji@linux-ipv6.org
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4B88BE39.6050307@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

(2010/02/27 15:39), Shan Wei wrote:
> Register nf_conntrack_frag6_{timeout,high_thresh,low_thresh} sysctls per-netns.
> nf_conntrack_frag6_timeout and ip6frag_time, nf_conntrack_frag6_low_thresh and ip6frag_low_thresh,
> nf_conntrack_frag6_high_thresh and ip6frag_high_thresh, the three sets are equivalent.
> The former sysctls are just an alias for he latter ones of IPv6.
>
> More discussion about it, see http://marc.info/?l=netfilter-devel&m=126709777922959&w=2.

As I mailed in reply to [0/7], I'm not for this,
because the context (including parameters) should be kept
separated between defragmentation in core ipv6 and one in netfilter.

--yoshfuji
