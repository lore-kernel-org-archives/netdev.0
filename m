From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND] isdn: fix NUL (\0 or \x00) specification in
 string
Date: Mon, 12 Jan 2015 15:32:11 -0500 (EST)
Message-ID: <20150112.153211.1568185988607410812.davem@davemloft.net>
References: <1420394722-20197-1-git-send-email-me@mortis.eu>
	<1420657812-19445-1-git-send-email-me@mortis.eu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, dsterba@suse.cz, mac@melware.de,
	isdn@linux-pingi.de, netdev@vger.kernel.org
To: me@mortis.eu
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1420657812-19445-1-git-send-email-me@mortis.eu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Giel van Schijndel <me@mortis.eu>
Date: Wed,  7 Jan 2015 20:10:12 +0100

> In C one can either use '\0' or '\x00' (or '\000') to add a NUL byte to
> a string. '\0x00' isn't part of these and will in fact result in a
> single NUL followed by "x00". This fixes that.
> 
> Signed-off-by: Giel van Schijndel <me@mortis.eu>
> Reported-at: http://www.viva64.com/en/b/0299/

Applied, thank you.
