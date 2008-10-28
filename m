From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
Date: Tue, 28 Oct 2008 15:44:18 -0700 (PDT)
Message-ID: <20081028.154418.132521921.davem@davemloft.net>
References: <1225100005.29750.46.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: johaahn@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43125
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752219AbYJ1Wok (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 18:44:40 -0400
In-Reply-To: <1225100005.29750.46.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johann Baudy <johaahn@gmail.com>
Date: Mon, 27 Oct 2008 10:33:25 +0100

> @@ -100,7 +101,7 @@ struct tpacket2_hdr
>  enum tpacket_versions
>  {
>  	TPACKET_V1,
> -	TPACKET_V2,
> +	TPACKET_V2
>  };
>  
>  /*

Please don't do this, the comma there is intentional.

If a future patch adds a new version, the diff will be the
addition of one new line, instead of one changed line and one
new line.
