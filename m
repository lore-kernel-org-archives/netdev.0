From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 2/3] PPTP: PPP over IPv4 (Point-to-Point Tunneling
 Protocol)
Date: Wed, 4 Aug 2010 10:24:31 -0700
Message-ID: <20100804102431.4cec4313@nehalam>
References: <E1OgbTZ-0006nb-00.xeb-mail-ru@f279.mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xeb@mail.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56175 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756356Ab0HDRYe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Aug 2010 13:24:34 -0400
In-Reply-To: <E1OgbTZ-0006nb-00.xeb-mail-ru@f279.mail.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 04 Aug 2010 14:45:33 +0400
xeb@mail.ru wrote:

> +struct pptp_gre_header {
> +  u_int8_t flags;		/* bitfield */
> +  u_int8_t ver;			/* should be PPTP_GRE_VER (enhanced GRE) */
> +  u_int16_t protocol;		/* should be PPTP_GRE_PROTO (ppp-encaps) */
> +  u_int16_t payload_len;	/* size of ppp payload, not inc. gre header */
> +  u_int16_t call_id;		/* peer's call_id for this session */
> +  u_int32_t seq;		/* sequence number.  Present if S==1 */
> +  u_int32_t ack;		/* seq number of highest packet recieved by */
> +  			

Use u8, u16, u32 in kernel code.

-- 
