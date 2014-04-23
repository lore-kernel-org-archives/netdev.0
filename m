From: Josh Boyer <jwboyer@fedoraproject.org>
Subject: Re: [PATCH 3.13] core, nfqueue, openvswitch: Orphan frags in
 skb_zerocopy and handle errors
Date: Wed, 23 Apr 2014 09:31:25 -0400
Message-ID: <CA+5PVA4pPG9yVO1C1JnkxV3mSdAqh3QB44Y8xsVRvQv5PHM-Ag@mail.gmail.com>
References: <1395873465-22282-1-git-send-email-zoltan.kiss@citrix.com>
	<20140327.152956.1528740039185894234.davem@davemloft.net>
	<20140421112601.GC3200@hercules>
	<1398181118.3624.203.camel@deadeye.wl.decadent.org.uk>
	<5356AEBF.5010505@citrix.com>
	<1398194284.7767.101.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>,
	Luis Henriques <luis.henriques@canonical.com>,
	David Miller <davem@davemloft.net>, jesse@nicira.com,
	pshelar@nicira.com, Thomas Graf <tgraf@redhat.com>,
	dev@openvswitch.org, pablo@netfilter.org, kadlec@blackhole.kfki.hu,
	edumazet@google.com, Daniel Borkmann <dborkman@redhat.com>,
	Tom Herbert <therbert@google.com>, jasowang@redhat.com,
	fw@strlen.de, Joe Perches <joe@perches.com>, horms@verge.net.au,
	jiri@resnulli.us, mst@redhat.com, Paul.Durrant@citrix.com,
	Jan Beulich <JBeulich@suse.com>,
	Herbert Xu <herbert@gondor.apana.org.au>, mszeredi@suse.cz,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	xen-devel@lists.xenproject.org, netdev <netdev@vger.kernel.org>,
	"Linux-Kernel@Vger. Kernel. Org" <linux-kernel@vger.kernel.org>,
	KVM list <kvm@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <1398194284.7767.101.camel@deadeye.wl.decadent.org.uk>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 22, 2014 at 3:18 PM, Ben Hutchings <ben@decadent.org.uk> wrote:
> From: Zoltan Kiss <zoltan.kiss@citrix.com>
>
> commit 36d5fe6a000790f56039afe26834265db0a3ad4c upstream.
>
> skb_zerocopy can copy elements of the frags array between skbs, but it doesn't
> orphan them. Also, it doesn't handle errors, so this patch takes care of that
> as well, and modify the callers accordingly. skb_tx_error() is also added to
> the callers so they will signal the failed delivery towards the creator of the
> skb.
>
> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> [bwh: Backported to 3.13: skb_zerocopy() is new in 3.14, but was moved from a
>  static function in nfnetlink_queue.  We need to patch that and its caller, but
>  not openvswitch.]
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>

Deja-vu.  I sent almost the same patch to netdev a while ago and you
acked it there.  So I guess I'll ack your copy as well :).  Not sure
why either version wasn't picked up by Dave.

josh
