From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 17/21] e1000: add ich8lan core functions
Date: Mon, 26 Jun 2006 21:52:25 -0400
Message-ID: <44A08F59.6030700@pobox.com>
References: <20060622051815.25497.89192.stgit@gitlost.site> <20060622052043.25497.85145.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48852 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1030601AbWF0Bw1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jun 2006 21:52:27 -0400
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
In-Reply-To: <20060622052043.25497.85145.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> This implements the core new functions needed for ich8's internal
> NIC. This includes:
> 
> * ich8 specific read/write code
> * flash/nvm access code
> * software semaphore flag functions
> * 10/100 PHY (fe - no gigabit speed) support for low-end versions
> * A workaround for a powerdown sequence problem discovered that
> affects a small number of motherboard.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  drivers/net/e1000/e1000_hw.c    | 1000 +++++++++++++++++++++++++++++++++++++++
>  drivers/net/e1000/e1000_hw.h    |  386 +++++++++++++++
>  drivers/net/e1000/e1000_osdep.h |   13 +
>  3 files changed, 1392 insertions(+), 7 deletions(-)

If it takes this much code to support ICH8, it seems like a e1000-ich8.c 
would be warranted...

	Jeff



