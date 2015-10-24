From: Jon Maloy <jon.maloy@ericsson.com>
Subject: RE: [RFC PATCH net-next] tipc: tipc_link_is_active() can be static
Date: Sat, 24 Oct 2015 18:49:59 +0000
Message-ID: <A2BAEFC30C8FD34388F02C9B3121859D22360FC4@eusaamb103.ericsson.se>
References: <201510242340.mc7bt8l1%fengguang.wu@intel.com>
 <20151024151100.GA46525@lkp-hsx03>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "kbuild-all@01.org" <kbuild-all@01.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: kbuild test robot <fengguang.wu@intel.com>,
	"kbuild-internal@linux.intel.com" <kbuild-internal@linux.intel.com>,
	"lkp@eclists.intel.com" <lkp@eclists.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usevmg21.ericsson.net ([198.24.6.65]:59346 "EHLO
	usevmg21.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751934AbbJXTFI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Oct 2015 15:05:08 -0400
In-Reply-To: <20151024151100.GA46525@lkp-hsx03>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Acked-by: Jon Maloy <jon.maloy@ericsson.com>



> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of kbuild test robot
> Sent: Saturday, 24 October, 2015 11:11
> To: kbuild-internal@linux.intel.com; lkp@eclists.intel.com
> Cc: kbuild-all@01.org; netdev@vger.kernel.org
> Subject: [RFC PATCH net-next] tipc: tipc_link_is_active() can be static
> 
> TO: "David S. Miller" <davem@davemloft.net>
> CC: netdev@vger.kernel.org
> CC: Jon Maloy <jon.maloy@ericsson.com>
> CC: Ying Xue <ying.xue@windriver.com>
> CC: tipc-discussion@lists.sourceforge.net
> CC: linux-kernel@vger.kernel.org
> 
> 
> Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
> ---
>  link.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/tipc/link.c b/net/tipc/link.c index 4449fa0..b637276 100644
> --- a/net/tipc/link.c
> +++ b/net/tipc/link.c
> @@ -173,7 +173,7 @@ bool link_is_bc_rcvlink(struct tipc_link *l)
>  	return ((l->bc_rcvlink == l) && !link_is_bc_sndlink(l));  }
> 
> -int tipc_link_is_active(struct tipc_link *l)
> +static int tipc_link_is_active(struct tipc_link *l)
>  {
>  	return l->active;
>  }
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in the body
> of a message to majordomo@vger.kernel.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html
