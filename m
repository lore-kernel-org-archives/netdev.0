From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 05/11] isdn/gigaset: improve CAPI message debugging
Date: Mon, 05 Jul 2010 19:23:56 -0700 (PDT)
Message-ID: <20100705.192356.52184135.davem@davemloft.net>
References: <20100705-patch-gigaset-00.tilman@imap.cc>
	<20100705-patch-gigaset-05.tilman@imap.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, hjlipp@web.de, keil@b1-systems.de,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: tilman@imap.cc
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100705-patch-gigaset-05.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tilman Schmidt <tilman@imap.cc>
Date: Tue,  6 Jul 2010 02:18:59 +0200 (CEST)

> @@ -384,7 +388,7 @@ void gigaset_skb_sent(struct bc_state *bcs, struct sk_buff *dskb)
>  
>  	/* don't send further B3 messages if disconnected */
>  	if (bcs->apconnstate < APCONN_ACTIVE) {
> -		gig_dbg(DEBUG_LLDATA, "disconnected, discarding ack");
> +		gig_dbg(DEBUG_MCMD, "disconnected, discarding ack");
>  		return;
>  	}

This is against something other than net-next-2.6 even with your
other two ISDN patches applied, because all of these lines read
"if (ap->connected ..."

Please tell me what exactly these patches are against so that I
can apply them to net-next-2.6 cleanly.
