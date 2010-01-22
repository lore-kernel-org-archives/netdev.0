From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH net-next-2.6 03/13] net-caif: add CAIF generic protocol
 stack header files
Date: Fri, 22 Jan 2010 10:28:17 +0100
Message-ID: <1264152497.3469.20.camel@violet>
References: <1264028130-14364-1-git-send-email-sjur.brandeland@stericsson.com>
	 <1264028130-14364-4-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	stefano.babic@babic.homelinux.org, randy.dunlap@oracle.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:38702 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753682Ab0AVJ1Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 04:27:16 -0500
In-Reply-To: <1264028130-14364-4-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sjur,

> Add include files for the generic CAIF protocol stack. This layer
> is somewhat generic in order to be able to use and test it outside
> the Linux Kernel.
> 
> caif_layer.h - Defines the structure of the CAIF protocol layers
> cfcnfg.h     - CAIF Configuration Module for services and link layers
> cfctrl.h     - CAIF Control Protocol Layer
> cffrml.h     - CAIF Framing Layer
> cfglue.h     - CAIF Glue Layer for allocation, logging etc
> cflist.h     - CAIF List implementation
> cfmuxl.h     - CAIF Muxing Layer
> cfpkt.h	     - CAIF Packet layer (skb helper functions)
> cfserl.h     - CAIF Serial Layer
> cfsrvl.h     - CAIF Service Layer
> 
> Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
> ---
>  include/net/caif/generic/caif_layer.h |  225 +++++++++++++++++++++++++++
>  include/net/caif/generic/cfcnfg.h     |  110 +++++++++++++
>  include/net/caif/generic/cfctrl.h     |  136 ++++++++++++++++
>  include/net/caif/generic/cffrml.h     |   19 +++
>  include/net/caif/generic/cfglue.h     |  110 +++++++++++++
>  include/net/caif/generic/cflst.h      |   19 +++
>  include/net/caif/generic/cfmuxl.h     |   22 +++
>  include/net/caif/generic/cfpkt.h      |  274 +++++++++++++++++++++++++++++++++
>  include/net/caif/generic/cfserl.h     |   14 ++
>  include/net/caif/generic/cfsrvl.h     |   33 ++++
>  10 files changed, 962 insertions(+), 0 deletions(-)

is it really needed to keep the "generic" piece in the path here. I
would prefer if we get rid of it.

Regards

Marcel


