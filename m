From: Tony Lindgren <tony@atomide.com>
Subject: Re: [PATCH 1/1] Revert "Prevent NUll pointer dereference with two
 PHYs on cpsw"
Date: Wed, 20 Apr 2016 08:05:34 -0700
Message-ID: <20160420150533.GH5995@atomide.com>
References: <1461163349-24696-1-git-send-email-andrew.goodbody@cambrionix.com>
 <1461163349-24696-2-git-send-email-andrew.goodbody@cambrionix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-omap@vger.kernel.org, mugunthanvnm@ti.com,
	grygorii.strashko@ti.com, davem@davemloft.net
To: Andrew Goodbody <andrew.goodbody@cambrionix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1461163349-24696-2-git-send-email-andrew.goodbody@cambrionix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Andrew Goodbody <andrew.goodbody@cambrionix.com> [160420 07:51]:
> This reverts commit cfe255600154f0072d4a8695590dbd194dfd1aeb
> 
> This can result in a "Unable to handle kernel paging request"
> during boot. This was due to using an uninitialised struct member,
> data->slaves.

Missing Signed-off-by?

This gets cpsw boards working in next for me again:

Tested-by: Tony Lindgren <tony@atomide.com>
