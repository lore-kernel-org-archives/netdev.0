From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net] hyperv: Fix a compiler warning in netvsc_send()
Date: Tue, 16 Apr 2013 13:31:05 -0700
Message-ID: <1366144265.28609.10.camel@joe-AO722>
References: <1366139031-12518-1-git-send-email-haiyangz@microsoft.com>
	 <20130416.151141.1928940532005718606.davem@davemloft.net>
	 <57e8f99081a94575a57cae5e93705c22@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
	 <20130416.154912.896506198616355113.davem@davemloft.net>
	 <b5d9b49f46ab434eb38a24e34f0b984b@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	KY Srinivasan <kys@microsoft.com>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>
To: Haiyang Zhang <haiyangz@microsoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:58629 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S936148Ab3DPUbG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Apr 2013 16:31:06 -0400
In-Reply-To: <b5d9b49f46ab434eb38a24e34f0b984b@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-04-16 at 20:18 +0000, Haiyang Zhang wrote:
> > From: David Miller [mailto:davem@davemloft.net] 
> > It works fine, but it's unclean.
> > Keep the req_id type as "u64", because that's what it is, a 64-bit request ID.
> I will make this update and submit a new patch, with the added comments.

Do you mean you'll use this to avoid compiler warnings?

	req_id = (u64)(unsigned long)packet;
