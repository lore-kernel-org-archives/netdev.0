From: David Miller <davem@davemloft.net>
Subject: Re: [RFC 2/2] ethtool: Add support for DMA Coalescing feature
 config to ethtool.
Date: Fri, 17 Jun 2011 14:54:20 -0400 (EDT)
Message-ID: <20110617.145420.866989290749857501.davem@davemloft.net>
References: <1308071606-6333-1-git-send-email-carolyn.wyborny@intel.com>
	<20110616.233354.508986372720173787.davem@davemloft.net>
	<EDC0E76513226749BFBC9C3FB031318F016EEF8A6E@orsmsx508.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com
To: carolyn.wyborny@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56168 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751880Ab1FQSy0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 14:54:26 -0400
In-Reply-To: <EDC0E76513226749BFBC9C3FB031318F016EEF8A6E@orsmsx508.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Date: Fri, 17 Jun 2011 08:50:11 -0700

> I will add a fuller description of the feature in my updated patch.
> I thought the feature was more well known. Quick description is that
> it's a power saving feature that causes the adapter to coalesce its
> DMA writes at low traffic times to save power on the platform by
> reducing wakeups.  The parameter is intended as a simple u32 value,
> not just an on or off, but also to allow a variety of configuration
> by adapter vendors, with validation of the input on the driver side.
> Since I left out the implementation in my patch, this wasn't clear.
> I will also fix this in my next submission.

The value cannot have adapter specific meaning, you must define it
precisely and in a generic manner, such that the user can specify the
same setting across different card types.
