From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net] hyperv: Fix a compiler warning in netvsc_send()
Date: Tue, 16 Apr 2013 20:45:12 +0000
Message-ID: <b7c7793f69d845e38825899a1500d47e@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
References: <1366139031-12518-1-git-send-email-haiyangz@microsoft.com>
	 <20130416.151141.1928940532005718606.davem@davemloft.net>
	 <57e8f99081a94575a57cae5e93705c22@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
	 <20130416.154912.896506198616355113.davem@davemloft.net>
	 <b5d9b49f46ab434eb38a24e34f0b984b@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
 <1366144265.28609.10.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	KY Srinivasan <kys@microsoft.com>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na01-by1-obe.ptr.o365filtering.com ([64.4.22.89]:22415 "EHLO
	na01-by1-obe.outbound.o365filtering.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S964981Ab3DPUqn convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Apr 2013 16:46:43 -0400
In-Reply-To: <1366144265.28609.10.camel@joe-AO722>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Joe Perches [mailto:joe@perches.com]
> Sent: Tuesday, April 16, 2013 4:31 PM
> To: Haiyang Zhang
> Cc: David Miller; netdev@vger.kernel.org; KY Srinivasan; olaf@aepfle.de;
> jasowang@redhat.com; linux-kernel@vger.kernel.org;
> devel@linuxdriverproject.org
> Subject: Re: [PATCH net] hyperv: Fix a compiler warning in netvsc_send()
> 
> On Tue, 2013-04-16 at 20:18 +0000, Haiyang Zhang wrote:
> > > From: David Miller [mailto:davem@davemloft.net] It works fine, but
> > > it's unclean.
> > > Keep the req_id type as "u64", because that's what it is, a 64-bit request
> ID.
> > I will make this update and submit a new patch, with the added comments.
> 
> Do you mean you'll use this to avoid compiler warnings?
> 
> 	req_id = (u64)(unsigned long)packet;

I will use:
req_id = (ulong)packet;

Assigning 32 bit integer to 64 bit variable is fine.

Thanks,
- Haiyang
