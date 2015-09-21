From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [PATCH] usbnet: New driver for QinHeng CH9200 devices
Date: Mon, 21 Sep 2015 08:36:29 +0200
Message-ID: <1442817389.1620.4.camel@suse.com>
References: <1442741138-8193-1-git-send-email-mjg59@coreos.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Matthew Garrett <mjg59@srcf.ucam.org>
To: Matthew Garrett <mjg59@coreos.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:57654 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756121AbbIUIlJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Sep 2015 04:41:09 -0400
In-Reply-To: <1442741138-8193-1-git-send-email-mjg59@coreos.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2015-09-20 at 02:25 -0700, Matthew Garrett wrote:
> There's a bunch of cheap USB 10/100 devices based on QinHeng chipsets.
> The
> vendor driver supports the CH9100 and CH9200 devices, but the majority
> of
> the code is of the if (ch9100) {} else {} form, with the most
> significant
> difference being that CH9200 provides a real MII interface but CH9100
> fakes
> one with a bunch of global variables and magic commands. I don't have
> a
> CH9100, so it's probably better if someone who does provides an
> independent
> driver for it. In any case, this is a lightly cleaned up version of
> the
> vendor driver with all the CH9100 code dropped.

Hi,

surprisingly nice for a vendor driver. It even covers endianness
correctly. I'd say that the remaining issues will be easy to fix
and that would be easier on a merged driver.

	Regards
		Oliver
