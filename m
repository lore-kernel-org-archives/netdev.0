From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH -FIX] e100: fix irq leak on suspend/resume
Date: Tue, 30 Jan 2007 09:37:45 -0500
Message-ID: <45BF5839.3030202@pobox.com>
References: <20070129223116.1AB3F418CA@ahkok-mobl.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Frederik Deweerdt <frederik.deweerdt@gmail.com>,
	netdev@vger.kernel.org
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46138 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965507AbXA3Oht (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Jan 2007 09:37:49 -0500
In-Reply-To: <20070129223116.1AB3F418CA@ahkok-mobl.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> e100: fix irq leak on suspend/resume
> 
> From: Frederik Deweerdt <frederik.deweerdt@gmail.com>
> 
> The e100_resume() function should be calling netif_device_detach and
> free_irq. This fixes multiple irq's being allocated after resume.
> 
> Signed-off-by: Frederik Deweerdt <frederik.deweerdt@gmail.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

applied


