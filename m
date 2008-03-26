From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] e1000e: test MSI interrupts
Date: Wed, 26 Mar 2008 14:42:25 -0400
Message-ID: <47EA9911.8040101@garzik.org>
References: <20080326183631.25114.90265.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:35012 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758571AbYCZSm1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Mar 2008 14:42:27 -0400
In-Reply-To: <20080326183631.25114.90265.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Auke Kok wrote:
> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> Test the MSI interrupt physically once before assuming that it
> actually works. Several platforms have already come across that
> have non-functional MSI interrupts and this code will attempt
> to detect those safely. Once the test succeeds MSI interrupts
> will be enabled.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  drivers/net/e1000e/defines.h |    1 
>  drivers/net/e1000e/e1000.h   |    1 
>  drivers/net/e1000e/netdev.c  |  161 ++++++++++++++++++++++++++++++++++++++++--
>  3 files changed, 155 insertions(+), 8 deletions(-)

Ah, the perennial add-same-test-to-every-driver conundrum.

I think we are far enough along with MSI to _not_ do this anymore in 
drivers.

The platforms with MSI problems should be discovered, made public, and 
worked around.

Otherwise you hide the same problem, just for someone else to discover 
with another component of the machine.

	Jeff



