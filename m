From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] igb: add IGB_DCA instead of selecting INTEL_IOATDMA
Date: Tue, 21 Oct 2008 02:11:30 -0400
Message-ID: <48FD7292.5020401@garzik.org>
References: <20081017180831.15639.50705.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, brice@myri.com,
	dan.j.williams@intel.com, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, tiwai@suse.de, apw@shadowen.org,
	linuxppc-dev@ozlabs.org, sam@ravnborg.org,
	e1000-devel@lists.sourceforge.net, maciej.sosnowski@intel.com,
	bunk@kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46218 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753052AbYJUGLh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Oct 2008 02:11:37 -0400
In-Reply-To: <20081017180831.15639.50705.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher wrote:
> Add a bool IGB_DCA defined to y if IGB and DCA are enabled, but IGB isn't y while DCA=m.  And thus remove the need to select INTEL_IOATDMA when IGB is enabled, so that non-x86 architectures can build the igb driver.
> Based on work/patch from Brice Goglin <brice@myri.com>
> 
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

applied


