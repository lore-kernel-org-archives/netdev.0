From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] Add sysctl to set the advertised TCP initial receive
 window.
Date: Thu, 10 Dec 2009 08:57:19 -0800
Message-ID: <20091210085719.4dae2bce@nehalam>
References: <pvmfx7jbn2h.fsf@chavey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, therbert@google.com,
	chavey@google.com, joe@perches.com, eric.dumazet@gmail.com
To: chavey@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43085 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761181AbZLJQ5e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Dec 2009 11:57:34 -0500
In-Reply-To: <pvmfx7jbn2h.fsf@chavey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 09 Dec 2009 18:05:42 -0800
chavey@google.com wrote:

> @@ -221,6 +222,7 @@ struct tcp_options_received {
>  	u8	num_sacks;	/* Number of SACK blocks		*/
>  	u16	user_mss;  	/* mss requested by user in ioctl */
>  	u16	mss_clamp;	/* Maximal mss, negotiated at connection setup */
> +	u8	init_rcv_wnd;	/* TCP initial receive window in MSS */
>  };

You could use the hole in the structure:

                snd_wscale : 4, /* Window scaling received from sender  */
                rcv_wscale : 4; /* Window scaling to send to receiver   */
+	u8	init_rcv_wnd;	/* TCP initial receive window in MSS */
/*      SACKs data      */
        u8      num_sacks;      /* Number of SACK blocks        
