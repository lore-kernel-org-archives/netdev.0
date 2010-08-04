From: xeb@mail.ru
Subject: =?koi8-r?Q?Re=3A_[PATCH_2/3]_PPTP=3A_PPP_over_IPv4_(Point-to-Point_Tunneling_Protocol)?=
Date: Thu, 05 Aug 2010 00:51:11 +0400
Message-ID: <E1Ogkvf-00052E-00.xeb-mail-ru@f271.mail.ru>
References: <20100804102431.4cec4313@nehalam>
Reply-To: xeb@mail.ru
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from f271.mail.ru ([217.69.128.239]:34646 "EHLO f271.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934778Ab0HDUvQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Aug 2010 16:51:16 -0400
In-Reply-To: <20100804102431.4cec4313@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 4 Aug 2010 10:24:31 -0700 Stephen Hemminger <shemminger@vyatta.com> wrote:

> On Wed, 04 Aug 2010 14:45:33 +0400
> xeb@mail.ru wrote:
> 
> > +struct pptp_gre_header {
> > +  u_int8_t flags;		/* bitfield */
> > +  u_int8_t ver;			/* should be PPTP_GRE_VER (enhanced GRE) */
> > +  u_int16_t protocol;		/* should be PPTP_GRE_PROTO (ppp-encaps) */
> > +  u_int16_t payload_len;	/* size of ppp payload, not inc. gre header */
> > +  u_int16_t call_id;		/* peer's call_id for this session */
> > +  u_int32_t seq;		/* sequence number.  Present if S==1 */
> > +  u_int32_t ack;		/* seq number of highest packet recieved by */
> > +  			
> 
> Use u8, u16, u32 in kernel code.

ok
