From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] usbnet: New driver for QinHeng CH9200 devices
Date: Mon, 21 Sep 2015 16:17:11 -0700 (PDT)
Message-ID: <20150921.161711.629698208228095818.davem@davemloft.net>
References: <1442741138-8193-1-git-send-email-mjg59@coreos.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oneukum@suse.com, mjg59@srcf.ucam.org
To: mjg59@coreos.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56332 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757197AbbIUXRM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 19:17:12 -0400
In-Reply-To: <1442741138-8193-1-git-send-email-mjg59@coreos.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Garrett <mjg59@coreos.com>
Date: Sun, 20 Sep 2015 02:25:38 -0700

> From: Matthew Garrett <mjg59@srcf.ucam.org>
> 
> There's a bunch of cheap USB 10/100 devices based on QinHeng chipsets. The
> vendor driver supports the CH9100 and CH9200 devices, but the majority of
> the code is of the if (ch9100) {} else {} form, with the most significant
> difference being that CH9200 provides a real MII interface but CH9100 fakes
> one with a bunch of global variables and magic commands. I don't have a
> CH9100, so it's probably better if someone who does provides an independent
> driver for it. In any case, this is a lightly cleaned up version of the
> vendor driver with all the CH9100 code dropped.
> 
> Signed-off-by: Matthew Garrett <mjg59@srcf.ucam.org>

Applied, thanks.
