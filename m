From: David Miller <davem@davemloft.net>
Subject: Re: pull request: wireless 2013-06-25
Date: Tue, 25 Jun 2013 16:05:27 -0700 (PDT)
Message-ID: <20130625.160527.623885667817641809.davem@davemloft.net>
References: <20130625174507.GB31220@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130625174507.GB31220@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Tue, 25 Jun 2013 13:45:07 -0400

> A few more late-breaking fixes hoping for 3.10...
> 
> Regarding the Bluetooth fix, Gustavo says:
> 
> "A important fix to 3.10, this patch fixes an issues that was preventing
> the l2cap info response command to be handled properly."
> 
> Also for that Bluetooth fix, Johan adds:
> 
> "Once the code gives up parsing this PDU it also gives up essential
> parts of the L2CAP connection creation process, i.e. without this
> patch the stack will fail to establish connections properly."
> 
> Moving onto ath9k, Felix Fietkau fixes an RCU locking issue in
> the transmit path.  As for ath9k_htc, Sujith Manoharan fixes some
> authentication timeouts by ensuring that a chip reset is done when
> IDLE is turned off.
> 
> I think these are all micro-fixes that shouldn't cause any trouble.
> Please let me know if there are problems!

Pulled, thanks John.
