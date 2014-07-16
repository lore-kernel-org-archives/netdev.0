From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] net: ppp: reset nextseq counter when
 enabling SC_MULTILINK
Date: Tue, 15 Jul 2014 22:52:59 -0700 (PDT)
Message-ID: <20140715.225259.1933230941203001162.davem@davemloft.net>
References: <53C4F987.1040401@kristov.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-ppp@vger.kernel.org, paulus@samba.org
To: develop@kristov.de
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <53C4F987.1040401@kristov.de>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christoph Schulz <develop@kristov.de>
Date: Tue, 15 Jul 2014 11:51:03 +0200

> From: Christoph Schulz <develop@kristov.de>
> 
> If using a demand-dialled PPP unit for a PPP multilink master, the pppd
> daemon needs to reset the sequence counter between two connections. This
> allows the daemon to reuse the PPP unit instead of destroying and recreating
> it. As there is no API to reset the counter, this patch resets the counter
> whenever the SC_MULTILINK flag is set.
> 
> Signed-off-by: Christoph Schulz <develop@kristov.de>
> ---
> Note that the stock pppd does not yet support multilink PPP over a
> demand-dialled interface. I used a locally patched version for testing.

Applied, thanks Christoph.
