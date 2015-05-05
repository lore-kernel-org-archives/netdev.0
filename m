From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 6/6] mpls: Add MPLS entropy label in flow_keys
Date: Mon, 4 May 2015 17:56:10 -0700
Message-ID: <20150505005609.GA14825@Alexeis-MacBook-Pro.local>
References: <1430780560-2758924-1-git-send-email-tom@herbertland.com>
 <1430780560-2758924-7-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:35396 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750887AbbEEA4O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 20:56:14 -0400
Received: by pabtp1 with SMTP id tp1so175771039pab.2
        for <netdev@vger.kernel.org>; Mon, 04 May 2015 17:56:14 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1430780560-2758924-7-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 04, 2015 at 04:02:40PM -0700, Tom Herbert wrote:
> In flow dissector if an MPLS header contains an entropy label this is
> saved in the new extra entropy field of flow_keys. The entropy label is
> then represented in the flow hash function input.
> 
> Signed-off-by: Tom Herbert <tom@herbertland.com>
> ---
>  include/uapi/linux/in.h   |  2 ++
>  include/uapi/linux/mpls.h |  3 +++
>  net/core/flow_dissector.c | 27 +++++++++++++++++++++++++++
>  3 files changed, 32 insertions(+)
> 
> diff --git a/include/uapi/linux/in.h b/include/uapi/linux/in.h
> index 589ced0..c86f6ab 100644
> --- a/include/uapi/linux/in.h
> +++ b/include/uapi/linux/in.h
> @@ -69,6 +69,8 @@ enum {
>  #define IPPROTO_SCTP		IPPROTO_SCTP
>    IPPROTO_UDPLITE = 136,	/* UDP-Lite (RFC 3828)			*/
>  #define IPPROTO_UDPLITE		IPPROTO_UDPLITE
> +  IPPROTO_MPLS = 137,		/* MPLS in IP (RFC 4023)		*/
> +#define IPPROTO_MPLS		IPPROTO_SCTP

odd typo. was it tested?
