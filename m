From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: Re: [RFT/PATCH] 3c509: use proper suspend/resume API
Date: Wed, 15 Feb 2006 19:32:45 +0200
Message-ID: <1140024765.24898.8.camel@localhost>
References: <1139935173.22151.2.camel@localhost>
	 <20060215022523.1d21b9c9.akpm@osdl.org>
	 <Pine.LNX.4.58.0602151317110.14223@sbz-30.cs.Helsinki.FI>
	 <20060215124020.GA1508@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1946049AbWBORcs@vger.kernel.org>
To: Russell King <rmk+lkml@arm.linux.org.uk>
In-Reply-To: <20060215124020.GA1508@flint.arm.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 15, 2006 at 01:23:19PM +0200, Pekka J Enberg wrote:
> > Hmm. Either I am totally confused or we don't even attempt suspend/resume 
> > for eisa and mca bus devices. Care to try this patch?

On Wed, 2006-02-15 at 12:40 +0000, Russell King wrote:
> Please don't use struct device_driver suspend/resume methods.

So what would be more appropriate? Move suspend/resume/probe and friends
to eisa_driver and mca_driver?

			Pekka
