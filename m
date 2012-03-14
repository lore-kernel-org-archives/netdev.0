From: David Miller <davem@davemloft.net>
Subject: Re: [net 2/2] net: fix a bug of dropping FCoE frames when
 disabling tx ip checksum
Date: Wed, 14 Mar 2012 14:53:29 -0700 (PDT)
Message-ID: <20120314.145329.240390897242258725.davem@davemloft.net>
References: <1331708518-28120-2-git-send-email-jeffrey.t.kirsher@intel.com>
	<1331757355.2564.31.camel@bwh-desktop.uk.solarflarecom.com>
	<138EA028228D124A900F5E6746F3C2160F6B3176@ORSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: yi.zou@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48360 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932388Ab2CNVze (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2012 17:55:34 -0400
In-Reply-To: <138EA028228D124A900F5E6746F3C2160F6B3176@ORSMSX102.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Zou, Yi" <yi.zou@intel.com>
Date: Wed, 14 Mar 2012 20:48:03 +0000

> CHECKSUM_UNNECESSARY sounds good to me, if it's ok to be used on the tx path
> as well, I think so but I am not 100% sure, it'd resolve this for fcoe and sctp
> like, downside is it's a bigger change that requires corresponding changes in
> these protocol driver stacks as well.

This is definitely the way this bug should be fixed, CHECKSUM_PARTIAL should
never be set for packets outside of the domain that value was designed for.
