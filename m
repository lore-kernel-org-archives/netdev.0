From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH v13 net-next 1/1] hv_sock: introduce Hyper-V Sockets
Date: Thu, 30 Jun 2016 14:33:19 +0000
Message-ID: <CY1PR03MB218662883B42266C3BF5F3F4BF240@CY1PR03MB2186.namprd03.prod.outlook.com>
References: <CO2PR03MB2182E76562A8236C5ABEA71CBF230@CO2PR03MB2182.namprd03.prod.outlook.com>
 <20160630.084454.396711639535557444.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"apw@canonical.com" <apw@canonical.com>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	"vkuznets@redhat.com" <vkuznets@redhat.com>,
	"cavery@redhat.com" <cavery@redhat.com>,
	KY Srinivasan <kys@microsoft.com>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	"joe@perches.com" <joe@perches.com>,
	"rolf.neugebauer@docker.com" <rolf.neugebauer@docker.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0111.outbound.protection.outlook.com ([65.55.169.111]:46504
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751987AbcF3Odc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 10:33:32 -0400
In-Reply-To: <20160630.084454.396711639535557444.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: David Miller [mailto:davem@davemloft.net]
> Sent: Thursday, June 30, 2016 20:45
> To: Dexuan Cui <decui@microsoft.com>
> Cc: gregkh@linuxfoundation.org; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; devel@linuxdriverproject.org; olaf@aepfle.de;
> apw@canonical.com; jasowang@redhat.com; vkuznets@redhat.com;
> cavery@redhat.com; KY Srinivasan <kys@microsoft.com>; Haiyang Zhang
> <haiyangz@microsoft.com>; joe@perches.com; rolf.neugebauer@docker.com
> Subject: Re: [PATCH v13 net-next 1/1] hv_sock: introduce Hyper-V Sockets
> 
> From: Dexuan Cui <decui@microsoft.com>
> Date: Wed, 29 Jun 2016 11:30:40 +0000
> 
> > @@ -1509,4 +1509,18 @@ static inline void commit_rd_index(struct
> vmbus_channel *channel)
> >  }
> >
> >
> > +struct vmpipe_proto_header {
> > +	u32 pkt_type;
> 
> It is wasteful to have two empty lines before this structure definition, one
> is sufficient.
> 
> ...

Hi David,
Thank you for pointing out the issues!

I'll fix all of them, and check all the similar issues in the patch.

Will post a new version ASAP.

Thanks,
-- Dexuan
