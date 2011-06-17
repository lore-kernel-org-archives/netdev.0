From: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Subject: RE: [RFC 2/2] ethtool: Add support for DMA Coalescing feature
 config to ethtool.
Date: Fri, 17 Jun 2011 08:50:11 -0700
Message-ID: <EDC0E76513226749BFBC9C3FB031318F016EEF8A6E@orsmsx508.amr.corp.intel.com>
References: <1308071606-6333-1-git-send-email-carolyn.wyborny@intel.com>
 <20110616.233354.508986372720173787.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:33523 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753993Ab1FQPuO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 11:50:14 -0400
In-Reply-To: <20110616.233354.508986372720173787.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>-----Original Message-----
>From: David Miller [mailto:davem@davemloft.net]
>Sent: Thursday, June 16, 2011 8:34 PM
>To: Wyborny, Carolyn
>Cc: netdev@vger.kernel.org; bhutchings@solarflare.com
>Subject: Re: [RFC 2/2] ethtool: Add support for DMA Coalescing feature
>config to ethtool.
>
>From: Carolyn Wyborny <carolyn.wyborny@intel.com>
>Date: Tue, 14 Jun 2011 10:13:26 -0700
>
>> This RFC patch adds functions to get and set DMA Coalescing feature
>> configuration.
>>
>> Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
>
>What in the world is "DMA Coalescing feature", what does it do?
>
>Might it want parameters and not just want to be turned on or off?
>
>This change, at a minimum, needs a more descriptive commit log entry.
>So that other driver authors can understand what exactly the feature
>is and therefore whether they might like to add support for it to
>their drivers.

I will add a fuller description of the feature in my updated patch.  I thought the feature was more well known. Quick description is that it's a power saving feature that causes the adapter to coalesce its DMA writes at low traffic times to save power on the platform by reducing wakeups.  The parameter is intended as a simple u32 value, not just an on or off, but also to allow a variety of configuration by adapter vendors, with validation of the input on the driver side.  Since I left out the implementation in my patch, this wasn't clear.  I will also fix this in my next submission.

Thanks,

Carolyn

Carolyn Wyborny
Linux Development
LAN Access Division
Intel Corporation



