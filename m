From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [net-next 12/14] igb: Add mechanism for detecting latched
 hardware Rx timestamp
Date: Thu, 17 Jan 2013 16:38:12 +0100
Message-ID: <20130117153812.GB2937@netboy.at.omicron.at>
References: <1358422519-20981-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1358422519-20981-13-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, Matthew Vick <matthew.vick@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:45541 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756289Ab3AQPiS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 10:38:18 -0500
Received: by mail-wg0-f50.google.com with SMTP id es5so1722917wgb.29
        for <netdev@vger.kernel.org>; Thu, 17 Jan 2013 07:38:17 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1358422519-20981-13-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 17, 2013 at 03:35:17AM -0800, Jeff Kirsher wrote:
> From: Matthew Vick <matthew.vick@intel.com>
> 
> Add a check against possible Rx timestamp freezing in the hardware via
> watchdog mechanism. This situation can occur when an Rx timestamp has been
> latched, but the packet has been dropped because the Rx ring is full.

Does this also need fixing in stable?

The igb patches look okay to me.

Acked-by: Richard Cochran <richardcochran@gmail.com>
