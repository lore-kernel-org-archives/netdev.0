From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v1] af_iucv: wrong mapping of sent and confirmed
 skbs
Date: Wed, 14 May 2014 15:38:59 -0400 (EDT)
Message-ID: <20140514.153859.1014576215594775653.davem@davemloft.net>
References: <20140513123802.GA60198@tuxmaker.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	stable@vger.kernel.org
To: blaschka@linux.vnet.ibm.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20140513123802.GA60198@tuxmaker.boeblingen.de.ibm.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Date: Tue, 13 May 2014 14:38:02 +0200

> From: Ursula Braun <ursula.braun@de.ibm.com>
> 
> When sending data through IUCV a MESSAGE COMPLETE interrupt
> signals that sent data memory can be freed or reused again.
> With commit f9c41a62bba3f3f7ef3541b2a025e3371bcbba97
> "af_iucv: fix recvmsg by replacing skb_pull() function" the
> MESSAGE COMPLETE callback iucv_callback_txdone() identifies
> the wrong skb as being confirmed, which leads to data corruption.
> This patch fixes the skb mapping logic in iucv_callback_txdone().
> 
> Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
> Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>

Applied, thank you.
