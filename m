From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] net: ppp: access ppp->nextseq only if
 CONFIG_PPP_MULTILINK is defined
Date: Wed, 16 Jul 2014 14:48:52 -0700 (PDT)
Message-ID: <20140716.144852.143826954917759282.davem@davemloft.net>
References: <53C6F186.30809@kristov.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-ppp@vger.kernel.org, paulus@samba.org
To: develop@kristov.de
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <53C6F186.30809@kristov.de>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christoph Schulz <develop@kristov.de>
Date: Wed, 16 Jul 2014 23:41:26 +0200

> From: Christoph Schulz <develop@kristov.de>
> 
> Commit d762d038497c9df51c19fcbe69b094b3bf8e5568 resets the counter holding the
> next sequence number for multilink PPP fragments to zero whenever the
> SC_MULTILINK flag is set. However, this counter only exists if
> CONFIG_PPP_MULTILINK is defined. Consequently, the new code has to be enclosed
> within #ifdef CONFIG_PPP_MULTILINK ... #endif.
> 
> Signed-off-by: Christoph Schulz <develop@kristov.de>

Applied, thanks.
