From: David Dillow <dave@thedillows.org>
Subject: Re: [PATCH 01/52] net: typhoon: remove unnecessary pci_set_drvdata()
Date: Wed, 11 Sep 2013 18:18:01 -0400
Message-ID: <1378937881.6649.6.camel@haswell.thedillows.org>
References: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
	 <004b01ceaebf$7e7e0e20$7b7a2a60$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "'David S. Miller'" <davem@davemloft.net>, netdev@vger.kernel.org
To: Jingoo Han <jg1.han@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from matrix.voodoobox.net ([75.127.97.206]:58717 "EHLO
	matrix.voodoobox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753792Ab3IKWpi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 18:45:38 -0400
In-Reply-To: <004b01ceaebf$7e7e0e20$7b7a2a60$%han@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-09-11 at 16:21 +0900, Jingoo Han wrote:
> The driver core clears the driver data to NULL after device_release
> or on probe failure. Thus, it is not needed to manually clear the
> device driver data to NULL.
> 
> Signed-off-by: Jingoo Han <jg1.han@samsung.com>

For what it is worth,

Acked-by: David Dillow <dave@thedillows.org>
