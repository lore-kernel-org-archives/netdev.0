From: Knut Petersen <Knut_Petersen@t-online.de>
Subject: Re: [BUG] sky2 broken for Yukon PCI-E Gigabit Ethernet Controller
 11ab:4362 (rev 19)
Date: Fri, 27 Jan 2006 17:04:13 +0100
Message-ID: <43DA447D.7050205@t-online.de>
References: <E1F1UqC-0002XE-00@gondolin.me.apana.org.au> <43D9B8A6.5020200@t-online.de> <20060127122242.GA32128@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751501AbWA0QGQ@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060127122242.GA32128@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:

>When we pull the PPP protocol off the skb, we forgot to update the
>hardware RX checksum.  This may lead to messages such as
>
>	dsl0: hw csum failure.
>
>Similarly, we need to clear the hardware checksum flag when we use
>the existing packet to store the decompressed result.
>
>Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>

ACK

That patch seems to solve all my problems with 
sky2 / pppoe / SuSE 9.2 Firewall. 

Thanks a lot!

cu,
 Knut
