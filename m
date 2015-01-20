From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [net-next PATCH v3 04/12] net: flow_table: create a set of
 common headers and actions
Date: Tue, 20 Jan 2015 15:59:38 -0500
Message-ID: <20150120205938.GD1854@tuxdriver.com>
References: <20150120202404.1741.8658.stgit@nitbit.x32>
 <20150120202752.1741.13810.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tgraf@suug.ch, simon.horman@netronome.com, sfeldma@gmail.com,
	netdev@vger.kernel.org, jhs@mojatatu.com, davem@davemloft.net,
	gerlitz.or@gmail.com, andy@greyhouse.net, ast@plumgrid.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:60565 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751649AbbATVP2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 16:15:28 -0500
Content-Disposition: inline
In-Reply-To: <20150120202752.1741.13810.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 20, 2015 at 12:27:53PM -0800, John Fastabend wrote:
> This adds common headers and actions that drivers can use.
> 
> I have not yet moved the header graphs into the common header
> because I'm not entirely convinced its re-usable. The devices
> I have been looking at have different enough header graphs that
> they wouldn't be re-usable. However possibly many 40Gbp NICs
> for example could share a common header graph. When we get
> multiple implementations we can move this into the common file
> if it makes sense.
> 
> And table structures seem to be unique enough that there is
> little value in putting each devices table layout into the
> common file so its left for device specific implementation.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>  include/linux/if_flow_common.h |  257 ++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 257 insertions(+)
>  create mode 100644 include/linux/if_flow_common.h
> 
> diff --git a/include/linux/if_flow_common.h b/include/linux/if_flow_common.h
> new file mode 100644
> index 0000000..ef2d66f
> --- /dev/null
> +++ b/include/linux/if_flow_common.h

<snip>

> +struct net_flow_action net_flow_pop_vlan = {
> +	.name = "pop_vlan",
> +	.uid = ACTION_POP_VLAN,
> +	.args = net_flow_null_args,
> +};

Random thought, should there be a "push_vlan" (for double VLAN tagging)?


-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
