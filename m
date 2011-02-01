From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] enc28j60: Fix reading of transmit status vector
Date: Mon, 31 Jan 2011 20:57:05 -0800 (PST)
Message-ID: <20110131.205705.59690433.davem@davemloft.net>
References: <1296253519-7580-1-git-send-email-weil@mail.berlios.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, tj@kernel.org, jpirko@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: weil@mail.berlios.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1296253519-7580-1-git-send-email-weil@mail.berlios.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stefan Weil <weil@mail.berlios.de>
Date: Fri, 28 Jan 2011 23:25:19 +0100

> This error was reported by cppcheck:
> drivers/net/enc28j60.c:815: error: Using sizeof for array given as function argument returns the size of pointer.
> 
> The original code reads 4 or 8 bytes instead of TSV_SIZE (= 100) bytes.
> I just fixed the code, but did not run any tests.
> 
> Signed-off-by: Stefan Weil <weil@mail.berlios.de>

Applied, thanks.
