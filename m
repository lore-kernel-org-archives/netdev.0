From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH/RFC iproute2/net-next 1/3] tc: flower: update headers
 for TCA_FLOWER_KEY_ICMP*
Date: Fri, 2 Dec 2016 15:06:53 -0800
Message-ID: <20161202150653.656e583b@xeon-e3>
References: <1480672785-14570-1-git-send-email-simon.horman@netronome.com>
        <1480672785-14570-2-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@mellanox.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:33105 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932165AbcLBXHC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 18:07:02 -0500
Received: by mail-pf0-f176.google.com with SMTP id d2so54843007pfd.0
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 15:07:01 -0800 (PST)
In-Reply-To: <1480672785-14570-2-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  2 Dec 2016 10:59:43 +0100
Simon Horman <simon.horman@netronome.com> wrote:

> These are proposed changes for net-next.
> 
> Signed-off-by: Simon Horman <simon.horman@netronome.com>
> ---
>  include/linux/pkt_cls.h | 10 ++++++++++
>  1 file changed, 10 insertions(+)
> 
> diff --git a/include/linux/pkt_cls.h b/include/linux/pkt_cls.h
> index a3d8a4f17d8e..fa435ea8ad21 100644
> --- a/include/linux/pkt_cls.h
> +++ b/include/linux/pkt_cls.h
> @@ -403,6 +403,16 @@ enum {
>  	TCA_FLOWER_KEY_ENC_UDP_SRC_PORT_MASK,	/* be16 */
>  	TCA_FLOWER_KEY_ENC_UDP_DST_PORT,	/* be16 */
>  	TCA_FLOWER_KEY_ENC_UDP_DST_PORT_MASK,	/* be16 */
> +
> +	TCA_FLOWER_KEY_ICMPV4_CODE,     /* u8 */
> +	TCA_FLOWER_KEY_ICMPV4_CODE_MASK,/* u8 */
> +	TCA_FLOWER_KEY_ICMPV4_TYPE,     /* u8 */
> +	TCA_FLOWER_KEY_ICMPV4_TYPE_MASK,/* u8 */
> +	TCA_FLOWER_KEY_ICMPV6_CODE,     /* u8 */
> +	TCA_FLOWER_KEY_ICMPV6_CODE_MASK,/* u8 */
> +	TCA_FLOWER_KEY_ICMPV6_TYPE,     /* u8 */
> +	TCA_FLOWER_KEY_ICMPV6_TYPE_MASK,/* u8 */
> +
>  	__TCA_FLOWER_MAX,
>  };
>  

I picked this up by updating from kernel headers.
