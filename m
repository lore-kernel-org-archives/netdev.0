From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 4/7 RESEND] cxgb3 - Update FW to 4.1
Date: Mon, 28 May 2007 18:41:15 -0400
Message-ID: <465B5A8B.7000701@garzik.org>
References: <20070526231748.12319.20729.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48895 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751442AbXE1WlR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 May 2007 18:41:17 -0400
In-Reply-To: <20070526231748.12319.20729.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

divy@chelsio.com wrote:
> From: Divy Le Ray <divy@chelsio.com>
> 
> Bump FW version to 4.1.
> Modify chip tuning in consequence.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>
> ---
> 
>  drivers/net/cxgb3/regs.h    |    4 ++++
>  drivers/net/cxgb3/t3_hw.c   |   40 ++++++++++++++++++++++------------------
>  drivers/net/cxgb3/version.h |    2 +-
>  3 files changed, 27 insertions(+), 19 deletions(-)

You think requiring a FIRMWARE UPGRADE is something that should be done 
in the middle of a kernel bugfix series?  What Q/A planet are you from?

This is a completely ridiculous burden you are placing on the individual 
user.  A good driver knows that firmware NOT SHIPPED WITH THE KERNEL 
does not necessarily move in lock-step with the kernel driver.  You are 
welcome to GPL your firmware and ship it of course....

	Jeff



