From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] myri10ge: remove broken select INTEL_IOATDMA from Kconfig
Date: Thu, 16 Oct 2008 05:10:08 -0400
Message-ID: <48F704F0.8060906@garzik.org>
References: <48F4FBE6.1010209@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Brice Goglin <brice@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:35993 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755008AbYJPJKN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Oct 2008 05:10:13 -0400
In-Reply-To: <48F4FBE6.1010209@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brice Goglin wrote:
> We cannot select INTEL_IOATDMA in Kconfig as soon as MYRI10GE is
> enabled since the former is not available on all architectures.
> Just use a Kconfig bool MYRI10GE_DCA set to =y when DCA support
> can actually be built in myri10ge (when DCA is enabled, except
> if MYRI10GE=y and DCA=m).
> 
> Signed-off-by: Brice Goglin <brice@myri.com>

applied this, and the same again to ixgbe


