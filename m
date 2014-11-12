From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net-next] hyperv: Add processing of MTU reduced by the
 host
Date: Wed, 12 Nov 2014 20:31:17 +0000
Message-ID: <c01728acfd564d779c1612539c65839e@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
References: <1415748472-27463-1-git-send-email-haiyangz@microsoft.com>
	<20141112.144640.703336197189868183.davem@davemloft.net>
	<ecc2fd8e646147fabb30d3120c889431@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
 <20141112.150423.1660890641226643870.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	KY Srinivasan <kys@microsoft.com>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"driverdev-devel@linuxdriverproject.org"
	<driverdev-devel@linuxdriverproject.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na01-by1-obe.ptr.o365filtering.com ([64.4.22.94]:48476 "EHLO
	na01-by1-obe.outbound.o365filtering.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753190AbaKLUbh convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Nov 2014 15:31:37 -0500
In-Reply-To: <20141112.150423.1660890641226643870.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Wednesday, November 12, 2014 3:04 PM
> To: Haiyang Zhang
> Cc: netdev@vger.kernel.org; KY Srinivasan; olaf@aepfle.de;
> jasowang@redhat.com; linux-kernel@vger.kernel.org; driverdev-
> devel@linuxdriverproject.org
> Subject: Re: [PATCH net-next] hyperv: Add processing of MTU reduced by
> the host
> 
> From: Haiyang Zhang <haiyangz@microsoft.com>
> Date: Wed, 12 Nov 2014 20:02:11 +0000
> 
> > The Hyper-V host doesn't support MTU below 1500. If we try setting MTU
> to a
> > value < 1500, the host will use 1500 automatically and return 1500 in
> the
> > RNDIS_OID_GEN_MAXIMUM_FRAME_SIZE query and guest will also use it.
> That's
> > why I set the lower limit to ETH_DATA_LEN.
> >
> > Are you suggesting that we keep the 68 as the lower limit, and let the
> host
> > auto-reset it to 1500 when we trying to set an MTU < 1500?
> 
> Then you need to add a comment, because without any information or
> context that change looks wrong.

I will add a comment.
Thanks,
- Haiyang
