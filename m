From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [NET-NEXT PATCH 01/25] ixgb: maybe stop tx port missed a piece
Date: Fri, 11 Jul 2008 01:21:56 -0400
Message-ID: <4876EDF4.1060000@garzik.org>
References: <20080708224858.6925.29725.stgit@localhost.localdomain> <20080708225107.6925.57805.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:49669 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751821AbYGKFWA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jul 2008 01:22:00 -0400
In-Reply-To: <20080708225107.6925.57805.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher wrote:
> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> 
> back when maybe stop tx was added to the ixgb driver some mistakes
> were made and the driver
> a) didn't remove the tx lock, which is now un-necessary
> b) didn't change the restart code to be compliant with maybe_stop
> 
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
> 
>  drivers/net/ixgb/ixgb_main.c |   15 ++++++++++-----
>  1 files changed, 10 insertions(+), 5 deletions(-)

applied 1-25


