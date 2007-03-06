From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 05/19] revert "drivers/net/tulip/dmfe: support basic carrier
 detection"
Date: Tue, 06 Mar 2007 06:11:12 -0500
Message-ID: <45ED4C50.8060600@garzik.org>
References: <200703061041.l26Afnqh019746@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, samuel.thibault@ens-lyon.org,
	stable@kernel.org, thomas@archlinux.org, val_henson@linux.intel.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53195 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965847AbXCFLLP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 06:11:15 -0500
In-Reply-To: <200703061041.l26Afnqh019746@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@linux-foundation.org wrote:
> From: Andrew Morton <akpm@linux-foundation.org>
> 
> Revert 7628b0a8c01a02966d2228bdf741ddedb128e8f8.  Thomas Bachler
> reports:
> 
>   Commit 7628b0a8c01a02966d2228bdf741ddedb128e8f8 (drivers/net/tulip/dmfe:
>   support basic carrier detection) breaks networking on my Davicom DM9009. 
>   ethtool always reports there is no link.  tcpdump shows incoming packets,
>   but TX is disabled.  Reverting the above patch fixes the problem.
> 
> 
> Cc: Samuel Thibault <samuel.thibault@ens-lyon.org>
> Cc: Jeff Garzik <jeff@garzik.org>
> Cc: Valerie Henson <val_henson@linux.intel.com>
> Cc: Thomas Bachler <thomas@archlinux.org>
> Cc: <stable@kernel.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/tulip/dmfe.c |    9 +--------
>  1 file changed, 1 insertion(+), 8 deletions(-)

applied patches 5-8


