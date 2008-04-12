From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH v2.6.26] gianfar: Support NAPI for TX Frames
Date: Sat, 12 Apr 2008 05:01:16 -0400
Message-ID: <48007A5C.7070609@pobox.com>
References: <1207787871-9164-1-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dai Haruki <dai.haruki@freescale.com>
To: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59337 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757018AbYDLJBT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Apr 2008 05:01:19 -0400
In-Reply-To: <1207787871-9164-1-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Fleming wrote:
> From: Dai Haruki <dai.haruki@freescale.com>
> 
> Poll the completed TX frames in gfar_poll().  This prevents the tx
> completion interrupt from interfering with processing of received
> frames.
> 
> We also disable hardware rx coalescing when NAPI is enabled.
> 
> Signed-off-by: Dai Haruki <dai.haruki@freescale.com>
> Signed-off-by: Andy Fleming <afleming@freescale.com>
> ---
>  drivers/net/gianfar.c |   56 ++++++++++++++++++++++++++++++++++++------------
>  drivers/net/gianfar.h |   13 +++++++++-
>  2 files changed, 53 insertions(+), 16 deletions(-)

applied


