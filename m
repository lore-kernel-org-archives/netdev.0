From: Valerie Henson <val_henson@linux.intel.com>
Subject: Re: tulip_stop_rxtx() failed
Date: Mon, 4 Dec 2006 22:34:10 -0800
Message-ID: <20061205063410.GE8482@goober>
References: <Pine.SOC.4.61.0611231347090.24112@math.ut.ee>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:42355 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S937455AbWLEG5r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Dec 2006 01:57:47 -0500
To: Meelis Roos <mroos@linux.ee>
Content-Disposition: inline
In-Reply-To: <Pine.SOC.4.61.0611231347090.24112@math.ut.ee>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 23, 2006 at 01:59:17PM +0200, Meelis Roos wrote:
> Background: Motorola Powerstack II (RS/6000 clone), PRep PowerPC 
> machine, running Debian unstable userspace and latest git kernels. 1 
> 21140 onboard, another in PCI slot.
> 
> Occasionally there is the message
> 0000:00:06.0: tulip_stop_rxtx() failed
> during bootup. It does not happen every time, just sometimes (about half 
> boots with different git kernels). Everything seems to be working fine 
> though. So this is nothing critical but just strange.

I'm planning on making that message print out only at debug level > 0.
It pops up on initialization of a couple of my cards, with no apparent
ill effects, and I've had reports of log spamming due to it.

-VAL
