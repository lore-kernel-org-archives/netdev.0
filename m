From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH flow-net-next] net: flow: Correct spelling of action
Date: Sun, 07 Dec 2014 17:36:19 -0800
Message-ID: <54850093.7050900@intel.com>
References: <1418001295-2389-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:34706 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751072AbaLHBga (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Dec 2014 20:36:30 -0500
In-Reply-To: <1418001295-2389-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/07/2014 05:14 PM, Simon Horman wrote:
> Signed-off-by: Simon Horman <simon.horman@netronome.com>
> ---
>  include/uapi/linux/if_flow.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/uapi/linux/if_flow.h b/include/uapi/linux/if_flow.h
> index 25aa744..9255990 100644
> --- a/include/uapi/linux/if_flow.h
> +++ b/include/uapi/linux/if_flow.h
> @@ -356,7 +356,7 @@ enum {
>   * @uid unique identifier for flow
>   * @priority priority to execute flow match/action in table
>   * @match null terminated set of match uids match criteria
> - * @actoin null terminated set of action uids to apply to match
> + * @action null terminated set of action uids to apply to match
>   *
>   * Flows must match all entries in match set.
>   */
> 

Great thanks Simon! Also I've added a bit so we can
distinguish between INGRESS pipelines and EGRESS pipelines
and a bunch of fixes to the netlink processing to check the
lengths correctly. I'll push those to my tree in the next day or
so. I'm also porting this to rocker switch now which I hope
should be ready in the next week for submitting.

Just to be clear this is against my git tree @

	https://github.com/jrfastab/flow-net-next/
