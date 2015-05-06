From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH 2/2] pktgen: introduce xmit_mode 'rx_inject'
Date: Tue, 05 May 2015 21:33:26 -0700
Message-ID: <55499996.2090308@plumgrid.com>
References: <20150505202730.8715.48527.stgit@ivy> <20150505202959.8715.51882.stgit@ivy>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:35510 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753048AbbEFEd3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 00:33:29 -0400
Received: by igbyr2 with SMTP id yr2so121150123igb.0
        for <netdev@vger.kernel.org>; Tue, 05 May 2015 21:33:28 -0700 (PDT)
In-Reply-To: <20150505202959.8715.51882.stgit@ivy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/5/15 1:30 PM, Jesper Dangaard Brouer wrote:
>
> Introduce xmit_mode 'rx_inject' for pktgen which generates the packets
> using familiar pktgen commands, but feeds them into
> netif_receive_skb() instead of ndo_start_xmit().
...
> pgset "xmit_mode rx_inject"

I think 'xmit_mode rx_inject' would make native english speaker cringe,
since it's saying 'transmit mode is receive' ... but I don't mind :)

>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
...
> @@ -251,13 +255,14 @@ struct pktgen_dev {
>   	 * we will do a random selection from within the range.
>   	 */
>   	__u32 flags;
> -	int removal_mark;	/* non-zero => the device is marked for
> -				 * removal by worker thread */
> -
> +	int xmit_mode;
>   	int min_pkt_size;
>   	int max_pkt_size;
>   	int pkt_overhead;	/* overhead for MPLS, VLANs, IPSEC etc */
>   	int nfrags;
> +	int removal_mark;	/* non-zero => the device is marked for
> +				 * removal by worker thread */

I'm not sure why you're moving removal_mark field.
Looks good. Thank you for doing this.
Ack. My SOB is already there :)

btw, these patches didn't reach my subscribed to netdev email yet...
something is stalling vger.
