From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] e1000: fix bug with shared interrupt during
 reset
Date: Tue, 27 Jan 2009 16:42:08 -0800 (PST)
Message-ID: <20090127.164208.04700459.davem@davemloft.net>
References: <20090127232714.24458.66863.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, jesse.brandeburg@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43830
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751586AbZA1AmK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 19:42:10 -0500
In-Reply-To: <20090127232714.24458.66863.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 27 Jan 2009 15:27:16 -0800

> A nasty bug was found where an MTU change (or anything else that caused a
> reset) could race with the interrupt code.  The interrupt code was entered
> by a shared interrupt during the MTU change.
> 
> This change prevents the interrupt code from running while the driver is in
> the middle of its reset path.
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>

Applied, thanks everyone.
