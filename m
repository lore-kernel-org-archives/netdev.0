From: Ben Greear <greearb@candelatech.com>
Subject: Re: [RFC 01/01]af_packet: Enhance network capture visibility
Date: Wed, 25 May 2011 16:10:22 -0700
Message-ID: <4DDD8C5E.7040207@candelatech.com>
References: <BANLkTimYVUkUWA2XPix2nUL-=rnQKghZQA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: chetan loke <loke.chetan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:43521 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752194Ab1EYXKZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2011 19:10:25 -0400
In-Reply-To: <BANLkTimYVUkUWA2XPix2nUL-=rnQKghZQA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/25/2011 04:03 PM, chetan loke wrote:
> This patch is not complete and is intended to:
> a) demonstrate the improvments
> b) gather suggestions
>
>
> Signed-off-by: Chetan Loke<lokec@ccs.neu.edu>

> +struct tpacket3_hdr {
> +	__u32		tp_status;
> +	__u32		tp_len;
> +	__u32		tp_snaplen;
> +	__u16		tp_mac;
> +	__u16		tp_net;
> +	__u32		tp_sec;
> +	__u32		tp_nsec;
> +	__u16		tp_vlan_tci;
> +	long		tp_next_offset;
> +};

Use fixed-size variables, like __u64 instead of 'long'.  That way,
you have the same sized msgs on 32 and 64-bit systems.

I didn't look at the rest of it in any detail, so no comment there.

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

