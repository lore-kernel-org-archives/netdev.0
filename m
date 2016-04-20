From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/1] Revert "Prevent NUll pointer dereference with
 two PHYs on cpsw"
Date: Wed, 20 Apr 2016 12:02:10 -0400 (EDT)
Message-ID: <20160420.120210.715003665474880360.davem@davemloft.net>
References: <1461165291-25043-1-git-send-email-andrew.goodbody@cambrionix.com>
	<1461165291-25043-2-git-send-email-andrew.goodbody@cambrionix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-omap@vger.kernel.org, mugunthanvnm@ti.com,
	grygorii.strashko@ti.com, tony@atomide.com
To: andrew.goodbody@cambrionix.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461165291-25043-2-git-send-email-andrew.goodbody@cambrionix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Goodbody <andrew.goodbody@cambrionix.com>
Date: Wed, 20 Apr 2016 16:14:51 +0100

> This reverts commit cfe255600154f0072d4a8695590dbd194dfd1aeb
> 
> This can result in a "Unable to handle kernel paging request"
> during boot. This was due to using an uninitialised struct member,
> data->slaves.
> 
> Signed-off-by: Andrew Goodbody <andrew.goodbody@cambrionix.com>
> Tested-by: Tony Lindgren <tony@atomide.com>
> ---
> 
> v2 No code change, added signoff and collected tested-by

Applied, thanks.
