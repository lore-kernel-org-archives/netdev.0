From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH v2 1/9] tproxy: split off ipv6 defragmentation to a separate
 module
Date: Thu, 21 Oct 2010 16:04:29 +0200
Message-ID: <4CC0486D.60703@trash.net>
References: <20101021104709.5192.31249.stgit@este.odu>	 <20101021104709.5192.64336.stgit@este.odu>  <4CC02456.4050301@trash.net> <1287661385.13326.45.camel@este.odu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Balazs Scheidler <bazsi@balabit.hu>,
	David Miller <davem@davemloft.net>
To: KOVACS Krisztian <hidden@balabit.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1287661385.13326.45.camel@este.odu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 21.10.2010 13:43, schrieb KOVACS Krisztian:
> tproxy: split off ipv6 defragmentation to a separate module
>     
>     Like with IPv4, TProxy needs IPv6 defragmentation but does not
>     require connection tracking. Since defragmentation was coupled
>     with conntrack, I split off the two, creating an nf_defrag_ipv6 module,
>     similar to the already existing nf_defrag_ipv4.

Applied, thanks.
