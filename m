From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] core, nfqueue, openvswitch: Orphan frags in
 skb_zerocopy and handle errors
Date: Wed, 26 Mar 2014 15:59:58 -0400 (EDT)
Message-ID: <20140326.155958.1928261590856069753.davem@davemloft.net>
References: <1395397894-9493-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesse@nicira.com, pshelar@nicira.com, tgraf@redhat.com,
	dev@openvswitch.org, pablo@netfilter.org, kadlec@blackhole.kfki.hu,
	edumazet@google.com, dborkman@redhat.com, therbert@google.com,
	jasowang@redhat.com, fw@strlen.de, joe@perches.com,
	horms@verge.net.au, jiri@resnulli.us, mst@redhat.com,
	Paul.Durrant@citrix.com, JBeulich@suse.com,
	herbert@gondor.apana.org.au, mszeredi@suse.cz,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	xen-devel@lists.xenproject.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org
To: zoltan.kiss@citrix.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1395397894-9493-1-git-send-email-zoltan.kiss@citrix.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zoltan Kiss <zoltan.kiss@citrix.com>
Date: Fri, 21 Mar 2014 10:31:34 +0000

> skb_zerocopy can copy elements of the frags array between skbs, but it doesn't
> orphan them. Also, it doesn't handle errors, so this patch takes care of that
> as well, and modify the callers accordingly. skb_tx_error() is also added to
> the callers so they will signal the failed delivery towards the creator of the
> skb.
> 
> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>

Applied, thanks Zoltan.
