From: Jeff Garzik <jeff@garzik.org>
Subject: Re: e1000: update device ID table for register dumps
Date: Fri, 09 Feb 2007 16:32:44 -0500
Message-ID: <45CCE87C.9040106@garzik.org>
References: <20070119225313.297224186C@ahkok-mobl.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60470 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752514AbXBIVcq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Feb 2007 16:32:46 -0500
In-Reply-To: <20070119225313.297224186C@ahkok-mobl.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> e1000: update device ID table for register dumps with new devices
> 
> From: Auke Kok <auke-jan.h.kok@intel.com>
> 
> The register dump routine of e1000 was missing several newer chipsets. I
> reimported the mac detection code from the linux e1000 driver. This fixes
> newer NIC's reporting that their bus type is PCI instead of PCI-e.
> 
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  e1000.c |  154 ++++++++++++++++++++++++++++++++++++++++++---------------------
>  1 files changed, 103 insertions(+), 51 deletions(-)

applied


