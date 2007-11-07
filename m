From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] ethtool: add support for supporting 10000baseT
Date: Wed, 07 Nov 2007 10:06:56 -0800
Message-ID: <4731FEC0.4020803@intel.com>
References: <20071107162420.5102.26358.stgit@localhost.localdomain> <20071107165749.GB3320@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:16135 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758972AbXKGSHV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Nov 2007 13:07:21 -0500
In-Reply-To: <20071107165749.GB3320@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Hutchings wrote:
> Auke Kok wrote:
>> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
>>
>> there is missing support in ethtool for reporting 10000baseT
>> as SUPPORTED_10000baseT_Full.  The code seems to be half
>> implemented because the "advertising" field has the implementation.
> 
> I reported this lack on Sourceforge a while back:
> <http://sourceforge.net/tracker/index.php?func=detail&aid=1798807&group_id=3242&atid=103242>
> Is anyone reading bugs reported there?

not really. However with plenty of new 10gig hardware going through here we're
currently looking at ethtool support and seeing if it misses anything. If you spot
issues, please Cc me or Jesse and netdev and of course Jeff Garzik so we can get
some patches out.

I just noticed an e1000 specific ethtool issue on there that we'll take a look at
as well.

Auke
