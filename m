From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/4] e1000: add module option to set transmit descriptor
 size
Date: Fri, 27 Jun 2008 01:10:37 -0400
Message-ID: <4864764D.6070802@garzik.org>
References: <20080619211850.GD22981@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40692 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752068AbYF0FKl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jun 2008 01:10:41 -0400
In-Reply-To: <20080619211850.GD22981@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Gospodarek wrote:
> This patch added the TxDescPower parameter to the e1000 module.  This
> parameter represents the size-order of each transmit descriptor.  The
> valid size for descriptors would be 2^7 (128) - 2^12 (4096) bytes each.
> As this value decreases one may want to consider increasing the
> TxDescriptors value to maintain the same amount of frame memory.  This
> patch does not change the defaults for any particular hardware model, so
> this will not have an effect on existing users.
> 
> The purpose of the patch is to address Tx Timeouts on 82545 and 82546
> chips that can show up during high-stress situations.  Decreasing the
> transmit descriptor size can shorten the amount of time that will be
> spent DMAing frames to the hardware and can reduce the likely-hood that
> Tx Timeouts will occur.
> 
> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> ---
>  drivers/net/e1000/e1000.h       |    6 ++++++
>  drivers/net/e1000/e1000_main.c  |   12 ++----------
>  drivers/net/e1000/e1000_param.c |   33 +++++++++++++++++++++++++++++++++++
>  3 files changed, 41 insertions(+), 10 deletions(-)

I don't see why a module parameter is needed.  In practice, nobody will 
ever think about this option, much less use it.


