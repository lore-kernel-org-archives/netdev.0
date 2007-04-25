From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [Fwd: [PATCH] [TIPC]: Enhancements to msg_set_bits() routine]
Date: Wed, 25 Apr 2007 18:39:43 +0200
Message-ID: <200704251839.44056.netdev@axxeo.de>
References: <462E52DE.5000900@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Per Liden <per.liden@ericsson.com>,
	"Stephens, Allan" <allan.stephens@windriver.com>
To: Jon Paul Maloy <jon.maloy@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:43682 "EHLO mail.axxeo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992847AbXDYQj6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Apr 2007 12:39:58 -0400
In-Reply-To: <462E52DE.5000900@ericsson.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jon,

Jon Paul Maloy schrieb:
> 2) The code has been optimized to minimize the number of run-time
>    endianness conversion operations by leveraging the fact that the
>    mask (and, in some cases, the value as well) is constant and the
>    necessary conversion can be performed by the compiler.

3) It can be checked by sparse, if you use proper types.
 
> diff --git a/net/tipc/msg.h b/net/tipc/msg.h
> index 62d5490..5c64e55 100644
> --- a/net/tipc/msg.h
> +++ b/net/tipc/msg.h
> @@ -71,8 +71,11 @@ static inline void msg_set_word(struct tipc_msg *m, u32
> w, u32 val) static inline void msg_set_bits(struct tipc_msg *m, u32 w,
>  				u32 pos, u32 mask, u32 val)

static inlinevoid msg_set_bits(struct tipc_msg *m, u32 w,
  				u32 pos, __be32 mask, __be32 val)


Care to resubmit?


Best Regards

Ingo Oeser
