From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3 1/2] net: ethernet: bgmac: init sequence bug
Date: Thu, 09 Feb 2017 17:04:22 -0500 (EST)
Message-ID: <20170209.170422.2219490608301068441.davem@davemloft.net>
References: <1486588377-7681-1-git-send-email-jon.mason@broadcom.com>
        <1486588377-7681-2-git-send-email-jon.mason@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rafal@milecki.pl, bcm-kernel-feedback-list@broadcom.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        zschroff@broadcom.com
To: jon.mason@broadcom.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1486588377-7681-2-git-send-email-jon.mason@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jon Mason <jon.mason@broadcom.com>
Date: Wed,  8 Feb 2017 16:12:56 -0500

> The code now checks to see if the adapter needs to be brought out of
> reset (where as before it was doing an IDM write to bring it out of
> reset regardless of whether it was in reset or not).  Also, removed
> unnecessary usleeps (as there is already a read present to flush the
> IDM writes).

That's not what the delays are there for, I don't think you can
safely remove them.

It's for waiting for the reset to complete after the write to
the register has propagated by the read back.

Please retain the delays.

Thanks.
