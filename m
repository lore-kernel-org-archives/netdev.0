From: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Subject: RE: [RFC 2/2] ethtool: Add support for DMA Coalescing feature
 config to ethtool.
Date: Tue, 21 Jun 2011 10:23:05 -0700
Message-ID: <EDC0E76513226749BFBC9C3FB031318F016F501D8D@orsmsx508.amr.corp.intel.com>
References: <1308071606-6333-1-git-send-email-carolyn.wyborny@intel.com>
	<20110616.233354.508986372720173787.davem@davemloft.net>
	<EDC0E76513226749BFBC9C3FB031318F016EEF8A6E@orsmsx508.amr.corp.intel.com>
 <20110617.145420.866989290749857501.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:65011 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752672Ab1FURXO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 13:23:14 -0400
In-Reply-To: <20110617.145420.866989290749857501.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>-----Original Message-----
>From: David Miller [mailto:davem@davemloft.net]
>Sent: Friday, June 17, 2011 11:54 AM
>To: Wyborny, Carolyn
>Cc: netdev@vger.kernel.org; bhutchings@solarflare.com
>Subject: Re: [RFC 2/2] ethtool: Add support for DMA Coalescing feature
>config to ethtool.
>
>From: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
>Date: Fri, 17 Jun 2011 08:50:11 -0700
>
>> I will add a fuller description of the feature in my updated patch.
>> I thought the feature was more well known. Quick description is that
>> it's a power saving feature that causes the adapter to coalesce its
>> DMA writes at low traffic times to save power on the platform by
>> reducing wakeups.  The parameter is intended as a simple u32 value,
>> not just an on or off, but also to allow a variety of configuration
>> by adapter vendors, with validation of the input on the driver side.
>> Since I left out the implementation in my patch, this wasn't clear.
>> I will also fix this in my next submission.
>
>The value cannot have adapter specific meaning, you must define it
>precisely and in a generic manner, such that the user can specify the
>same setting across different card types.

Ok, good point.  I will refine the definition of the parameter in the next submission, once the dust clears on the major revisions in progress.

Thanks,

Carolyn

Carolyn Wyborny
Linux Development
LAN Access Division
Intel Corporation


