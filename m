From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] wan/x25: Fix use-after-free in x25_asy_open_tty()
Date: Tue, 01 Dec 2015 15:18:02 -0500 (EST)
Message-ID: <20151201.151802.2271909049212392672.davem@davemloft.net>
References: <1448651919-4239-1-git-send-email-peter@hurleysoftware.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, jslaby@suse.cz,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	sasha.levin@oracle.com, stable@vger.kernel.org
To: peter@hurleysoftware.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1448651919-4239-1-git-send-email-peter@hurleysoftware.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Peter Hurley <peter@hurleysoftware.com>
Date: Fri, 27 Nov 2015 14:18:39 -0500

> The N_X25 line discipline may access the previous line discipline's closed
> and already-freed private data on open [1].
> 
> The tty->disc_data field _never_ refers to valid data on entry to the
> line discipline's open() method. Rather, the ldisc is expected to
> initialize that field for its own use for the lifetime of the instance
> (ie. from open() to close() only).
 ...
> Reported-and-tested-by: Sasha Levin <sasha.levin@oracle.com>
> Cc: <stable@vger.kernel.org>
> Signed-off-by: Peter Hurley <peter@hurleysoftware.com>

Applied, thanks.
