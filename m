From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] et131x: use msecs_to_jiffies for conversions
Date: Wed, 11 Feb 2015 19:38:09 -0800 (PST)
Message-ID: <20150211.193809.875269045307730921.davem@davemloft.net>
References: <1423646874-24403-1-git-send-email-hofrat@osadl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mark.einon@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: hofrat@osadl.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423646874-24403-1-git-send-email-hofrat@osadl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicholas Mc Guire <hofrat@osadl.org>
Date: Wed, 11 Feb 2015 04:27:54 -0500

> This is only an API consolidation and should make things more readable.
> Converting milliseconds to jiffies by "val * HZ / 1000" is technically
> OK but msecs_to_jiffies(val) is the cleaner solution and handles all
> corner cases correctly. This is a minor API cleanup only.
> 
> Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>

Applied, thanks.
