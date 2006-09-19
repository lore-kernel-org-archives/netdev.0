From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.18-rc7-mm1: networking breakage on HPC nx6325 + SUSE 10.1
Date: Tue, 19 Sep 2006 15:06:29 -0700 (PDT)
Message-ID: <20060919.150629.109607267.davem@davemloft.net>
References: <20060919133606.f0c92e66.akpm@osdl.org>
	<200609192330.34769.rjw@sisk.pl>
	<200609200006.53138.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, greg@kroah.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:36776
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751188AbWISWGY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Sep 2006 18:06:24 -0400
To: rjw@sisk.pl
In-Reply-To: <200609200006.53138.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Rafael J. Wysocki" <rjw@sisk.pl>
Date: Wed, 20 Sep 2006 00:06:52 +0200

> I _guess_ the problem is caused by
> gregkh-driver-network-class_device-to-device.patch, but I can't verify this,
> because the kernel (obviously) doesn't compile if I revert it.

Indeed.

I thought we threw this patch out because we knew it would cause
problems for existing systems?  I do remember Greg making an argument
as to why we needed the change, but that doesn't make breaking people's
systems legitimate in any way.

