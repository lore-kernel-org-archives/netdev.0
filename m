From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH V2] ibm_newemac:  Fixes kernel crashes when speed of cable
 connected changes
Date: Fri, 27 Jun 2008 01:14:30 -0400
Message-ID: <48647736.3080704@garzik.org>
References: <1214246162-25293-1-git-send-email-sr@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org, Sathya Narayanan <sathyan@teamf1.com>
To: Stefan Roese <sr@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:49060 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752261AbYF0FOg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jun 2008 01:14:36 -0400
In-Reply-To: <1214246162-25293-1-git-send-email-sr@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stefan Roese wrote:
> From: Sathya Narayanan <sathyan@teamf1.com>
> 
> The descriptor pointers were not initialized to NIL values, so it was
> poiniting to some random addresses which was completely invalid. This
> fix takes care of initializing the descriptor to NIL values and clearing
> the valid descriptors on clean ring operation.
> 
> Signed-off-by: Sathya Narayanan <sathyan@teamf1.com>
> Signed-off-by: Stefan Roese <sr@denx.de>
> ---
> Changed since V1:
> - Fixed off-by-one error in for loops
> 
>  drivers/net/ibm_newemac/core.c |    6 +++++-
>  1 files changed, 5 insertions(+), 1 deletions(-)

I didn't see any answers to ben h's questions?

Holding this patch, waiting for ben's ack...


