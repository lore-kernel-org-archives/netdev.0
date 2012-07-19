From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sfc: initialize dynamic sysfs attributes for lockdep
Date: Thu, 19 Jul 2012 10:51:10 -0700 (PDT)
Message-ID: <20120719.105110.453749599773620447.davem@davemloft.net>
References: <1342717485-24034-1-git-send-email-mschmidt@redhat.com>
	<1342718345.2617.46.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mschmidt@redhat.com, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46818 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752733Ab2GSRvL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 13:51:11 -0400
In-Reply-To: <1342718345.2617.46.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 19 Jul 2012 18:19:05 +0100

> On Thu, 2012-07-19 at 19:04 +0200, Michal Schmidt wrote:
>> Dynamically allocated sysfs attributes must be initialized using
>> sysfs_attr_init(), otherwise lockdep complains:
>> BUG: key <address> not in .data!
>>
>> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
> 
> Acked-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
