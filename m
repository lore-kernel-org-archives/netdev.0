From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [PATCH v2 net-next] xen-netback: add support for
 multicast control
Date: Thu, 03 Sep 2015 02:56:40 -0600
Message-ID: <55E82768020000780009F32F@prv-mh.provo.novell.com>
References: <1441213116-9038-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xenproject.org, Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>, netdev@vger.kernel.org
To: "Paul Durrant" <paul.durrant@citrix.com>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <1441213116-9038-1-git-send-email-paul.durrant@citrix.com>
Content-Disposition: inline
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

>>> On 02.09.15 at 18:58, <paul.durrant@citrix.com> wrote:
> @@ -1215,6 +1289,31 @@ static void xenvif_tx_build_gops(struct xenvif_queue *queue,
>  				break;
>  		}
>  
> +		if (extras[XEN_NETIF_EXTRA_TYPE_MCAST_ADD - 1].type) {
> +			struct xen_netif_extra_info *extra;
> +
> +			extra = &extras[XEN_NETIF_EXTRA_TYPE_MCAST_ADD - 1];
> +			ret = xenvif_mcast_add(queue->vif, extra->u.mcast.addr);

What's the reason this call isn't gated on vif->multicast_control?

Jan
