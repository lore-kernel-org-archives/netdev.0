From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: hdlc_ppp: why no detach()?
Date: Thu, 15 Apr 2010 02:02:59 +0200
Message-ID: <m3tyrdmvkc.fsf@intrepid.localdomain>
References: <4BC32B00.1030600@ruggedcom.com>
	<m3633todl2.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Julia Lawall <julia@diku.dk>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Michael Barkowski <michaelbarkowski@ruggedcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m3633todl2.fsf@intrepid.localdomain> (Krzysztof Halasa's message
	of "Thu, 15 Apr 2010 00:48:25 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> 1. The SCR packet will be delayed by 2 seconds (both first and second
>    SCR will be sent the same time). Perhaps we delay only a little
>    (instead of full 2 seconds) and only then send the initial packet.

BTW can I sleep in a netdevice_notifier callback, no?
-- 
Krzysztof Halasa
