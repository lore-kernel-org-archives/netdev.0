From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 5/14] nes: context structures and defines
Date: Tue, 07 Aug 2007 21:50:33 -0400
Message-ID: <46B92169.6020801@garzik.org>
References: <200708080103.l7813b7E004778@neteffect.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, ewg@lists.openfabrics.org,
	netdev@vger.kernel.org
To: ggrundstrom@neteffect.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:56295 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752302AbXHHBuh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Aug 2007 21:50:37 -0400
In-Reply-To: <200708080103.l7813b7E004778@neteffect.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ggrundstrom@neteffect.com wrote:
> QP context structures and defines
> 
> Signed-off-by: Glenn Grundstrom <ggrundstrom@neteffect.com>
> ---
> diff -Nurp NULL ofa_kernel-1.2/drivers/infiniband/hw/nes/nes_context.h
> --- NULL	1969-12-31 18:00:00.000000000 -0600
> +++ ofa_kernel-1.2/drivers/infiniband/hw/nes/nes_context.h	2007-08-06 20:09:04.000000000 -0500
> @@ -0,0 +1,193 @@
> +/*
> + * Copyright (c) 2006 NetEffect, Inc. All rights reserved.
> + *
> + * This software is available to you under a choice of one of two
> + * licenses.  You may choose to be licensed under the terms of the GNU
> + * General Public License (GPL) Version 2, available from the file
> + * COPYING in the main directory of this source tree, or the
> + * OpenIB.org BSD license below:
> + *
> + *     Redistribution and use in source and binary forms, with or
> + *     without modification, are permitted provided that the following
> + *     conditions are met:
> + *
> + *      - Redistributions of source code must retain the above
> + *        copyright notice, this list of conditions and the following
> + *        disclaimer.
> + *
> + *      - Redistributions in binary form must reproduce the above
> + *        copyright notice, this list of conditions and the following
> + *        disclaimer in the documentation and/or other materials
> + *        provided with the distribution.
> + *
> + * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
> + * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
> + * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
> + * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
> + * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
> + * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
> + * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
> + * SOFTWARE.
> + */
> +
> +#ifndef NES_CONTEXT_H
> +#define NES_CONTEXT_H
> +
> +struct nes_qp_context {
> +	u32   misc;
> +	u32   cqs;
> +	u32   sq_addr_low;
> +	u32   sq_addr_high;
> +	u32   rq_addr_low;
> +	u32   rq_addr_high;
> +	u32   misc2;
> +	u32   tcpPorts;
> +	u32   ip0;
> +	u32   ip1;
> +	u32   ip2;
> +	u32   ip3;
> +	u32   mss;
> +	u32   arp_index_vlan;
> +	u32   tcp_state_flow_label;
> +	u32   pd_index_wscale;
> +	u32   keepalive;
> +	u32   ts_recent;
> +	u32   ts_age;
> +	u32   snd_nxt;
> +	u32   snd_wnd;
> +	u32   rcv_nxt;
> +	u32   rcv_wnd;
> +	u32   snd_max;
> +	u32   snd_una;
> +	u32   srtt;
> +	u32   rttvar;
> +	u32   ssthresh;
> +	u32   cwnd;
> +	u32   snd_wl1;
> +	u32   snd_wl2;
> +	u32   max_snd_wnd;
> +	u32   ts_val_delta;
> +	u32   retransmit;
> +	u32   probe_cnt;
> +	u32   hte_index;
> +	u32   q2_addr_low;
> +	u32   q2_addr_high;
> +	u32   ird_index;
> +	u32   Rsvd3;
> +	u32   ird_ord_sizes;
> +	u32   mrkr_offset;
> +	u32   aeq_token_low;
> +	u32   aeq_token_high;

I presume this needs the __le32, etc., types?

I presume you have not yet run this through sparse?  Please read and 
follow Documentation/sparse.txt

	Jeff



