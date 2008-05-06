From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH v2.6.26] gianfar: Fix a locking bug in gianfar's sysfs
 code
Date: Tue, 06 May 2008 12:17:40 -0400
Message-ID: <482084A4.5020509@pobox.com>
References: <1209751230-25462-1-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:45260 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764130AbYEFQRm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 May 2008 12:17:42 -0400
In-Reply-To: <1209751230-25462-1-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Fleming wrote:
> During sparse cleanup, found a locking bug.  Some of the sysfs functions were
> acquiring a lock, and then returning in the event of an error.  We rearrange
> the code so that the lock is released in error conditions, too.
> 
> Signed-off-by: Andy Fleming <afleming@freescale.com>
> ---
>  drivers/net/gianfar.c       |    5 +++--
>  drivers/net/gianfar.h       |    3 +++
>  drivers/net/gianfar_sysfs.c |   10 ++++++----
>  3 files changed, 12 insertions(+), 6 deletions(-)

applied


