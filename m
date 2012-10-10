From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [PATCH 01/12] usbnet: introduce usbnet 3 command helpers
Date: Wed, 10 Oct 2012 19:45:50 +0800
Message-ID: <CACVXFVM2f4vY062D60MCJZ1fwvNvmx+PvjW-yvN0XGf+09EZmg@mail.gmail.com>
References: <1349160684-6627-1-git-send-email-ming.lei@canonical.com>
	<1631246.gHVDWoZpLi@linux-lqwf.site>
	<CACVXFVMq8-t2o5=M=3xCQEiPFXjvH14g3NtRgOTMYr542d5zXw@mail.gmail.com>
	<1691674.ASueyuVmUn@linux-lqwf.site>
	<CACVXFVPDg89y7LyKLA0YUN7oA2rGfptfHLZhJrqBjTVPjsGdNg@mail.gmail.com>
	<AE90C24D6B3A694183C094C60CF0A2F6026B702F@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Oliver Neukum <oneukum@suse.de>,
	"David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:48319 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751144Ab2JJLpw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2012 07:45:52 -0400
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B702F@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 10, 2012 at 7:25 PM, David Laight <David.Laight@aculab.com> wrote:

>
> What about the error handler/sleep/resume code calling into the
> memory allocator to indicate that all allocates be GFP_NOIO until
> it calls back to indicate that the restricted path is complete.
> Might be a per-cpu count?

IMO, it might be a per-task variable, but unfortunately no such
mechanism is provided by current kernel.

Thanks,
--
Ming Lei
