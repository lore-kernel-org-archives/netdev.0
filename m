From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] gianfar driver: eliminate compiler warnings and unnecessary
 macros
Date: Tue, 04 Dec 2007 15:15:08 -0500
Message-ID: <4755B54C.60504@pobox.com>
References: <20071202051245.8918.24063.stgit@trillian.secretlab.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	galak@kernel.crashing.org, afleming@freescale.com
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:51552 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751705AbXLDUPM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2007 15:15:12 -0500
In-Reply-To: <20071202051245.8918.24063.stgit@trillian.secretlab.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Grant Likely wrote:
> From: Grant Likely <grant.likely@secretlab.ca>
> 
> This patch eliminates the warning of unused return values when the driver
> registers it sysfs files.  Now the driver will print an error if it is
> unable to register the sysfs files.
> 
> It also eliminates the macros used to wrap the DEVICE_ATTR macro and the
> device_create_file function call.  The macros don't reduce the number of
> lines of source code in the file and the name munging makes is so that
> cscope and friends don't see the references to the functions.  It's better
> to just call the kernel API directly.
> 
> While we're at it, the DEVICE_ATTR instances have been moved down to
> be grouped with the functions they depend on.
> 
> Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
> ---
> 
>  drivers/net/gianfar_sysfs.c |   50 ++++++++++++++++++++++---------------------
>  1 files changed, 25 insertions(+), 25 deletions(-)

applied #upstream


