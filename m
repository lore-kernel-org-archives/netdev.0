From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [RFC] [PATCH 0/3] ioat: DMA engine support
Date: Wed, 23 Nov 2005 23:02:50 +0000
Message-ID: <1132786970.13095.35.camel@localhost.localdomain>
References: <Pine.LNX.4.44.0511231143380.32487-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	john.ronciak@intel.com, christopher.leech@intel.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932294AbVKWWaV@vger.kernel.org>
To: Andrew Grover <andrew.grover@intel.com>
In-Reply-To: <Pine.LNX.4.44.0511231143380.32487-100000@isotope.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mer, 2005-11-23 at 12:26 -0800, Andrew Grover wrote:
> early next year. Until then, the code doesn't really *do* anything, but we
> wanted to release what we could right away, and start getting some 
> feedback.

First comment partly based on Jeff Garziks comments - if you added an
"operation" to the base functions and an operation mask to the DMA
engines it becomes possible to support engines that can do other ops (eg
abusing an NCR53c8xx for both copy and clear).

Second one - you obviously tested this somehow, was that all done by
simulation or do you have a "CPU" memcpy test engine for use before the
hardware pops up ?
