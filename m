From: Mark Einon <mark.einon@gmail.com>
Subject: Re: [PATCH] et131x: use msecs_to_jiffies for conversions
Date: Wed, 11 Feb 2015 18:11:03 +0000
Message-ID: <20150211181103.GA19406@msilap.einon.net>
References: <1423646874-24403-1-git-send-email-hofrat@osadl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Nicholas Mc Guire <hofrat@osadl.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1423646874-24403-1-git-send-email-hofrat@osadl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 11, 2015 at 04:27:54AM -0500, Nicholas Mc Guire wrote:
> This is only an API consolidation and should make things more readable.
> Converting milliseconds to jiffies by "val * HZ / 1000" is technically
> OK but msecs_to_jiffies(val) is the cleaner solution and handles all
> corner cases correctly. This is a minor API cleanup only.
> 
> Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>

Acked-by: Mark Einon <mark.einon@gmail.com>
