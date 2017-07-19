From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v2 1/2] openvswitch: Optimize updating for OvS
 flow_stats.
Date: Wed, 19 Jul 2017 13:49:57 -0700 (PDT)
Message-ID: <20170719.134957.2287331374531494457.davem@davemloft.net>
References: <1500359286-36597-1-git-send-email-xiangxia.m.yue@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: xiangxia.m.yue-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1500359286-36597-1-git-send-email-xiangxia.m.yue-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://mail.openvswitch.org/mailman/options/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://mail.openvswitch.org/pipermail/ovs-dev/>
List-Post: <mailto:ovs-dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <https://mail.openvswitch.org/mailman/listinfo/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Tonghao Zhang <xiangxia.m.yue-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Mon, 17 Jul 2017 23:28:05 -0700

> In the ovs_flow_stats_update(), we only use the node
> var to alloc flow_stats struct. But this is not a
> common case, it is unnecessary to call the numa_node_id()
> everytime. This patch is not a bugfix, but there maybe
> a small increase.
> 
> Signed-off-by: Tonghao Zhang <xiangxia.m.yue-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Applied.
