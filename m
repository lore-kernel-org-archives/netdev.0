From: Russell King <rmk+lkml@arm.linux.org.uk>
Subject: Re: [RFT/PATCH] 3c509: use proper suspend/resume API
Date: Wed, 15 Feb 2006 12:40:20 +0000
Message-ID: <20060215124020.GA1508@flint.arm.linux.org.uk>
References: <1139935173.22151.2.camel@localhost> <20060215022523.1d21b9c9.akpm@osdl.org> <Pine.LNX.4.58.0602151317110.14223@sbz-30.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1945918AbWBOMk3@vger.kernel.org>
To: Pekka J Enberg <penberg@cs.Helsinki.FI>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0602151317110.14223@sbz-30.cs.Helsinki.FI>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 15, 2006 at 01:23:19PM +0200, Pekka J Enberg wrote:
> Hmm. Either I am totally confused or we don't even attempt suspend/resume 
> for eisa and mca bus devices. Care to try this patch?

Please don't use struct device_driver suspend/resume methods.

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:  2.6 Serial core
