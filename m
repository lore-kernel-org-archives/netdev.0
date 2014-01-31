From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] e100: Fix "disabling already-disabled device"
 warning
Date: Thu, 30 Jan 2014 16:45:38 -0800 (PST)
Message-ID: <20140130.164538.1074744859012249672.davem@davemloft.net>
References: <1391079064-18411-1-git-send-email-michele@acksyn.org>
	<20140130.162745.1556632155972070897.davem@davemloft.net>
	<309B89C4C689E141A5FF6A0C5FB2118B7314C041@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: michele@acksyn.org, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net, idirectscm@aim.com
To: aaron.f.brown@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32896 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753860AbaAaApi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jan 2014 19:45:38 -0500
In-Reply-To: <309B89C4C689E141A5FF6A0C5FB2118B7314C041@ORSMSX101.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Date: Fri, 31 Jan 2014 00:40:16 +0000

>> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
>> On Behalf Of David Miller
>> Sent: Thursday, January 30, 2014 4:28 PM
>> To: michele@acksyn.org
>> Cc: netdev@vger.kernel.org; e1000-devel@lists.sourceforge.net;
>> idirectscm@aim.com
>> Subject: Re: [PATCH net] e100: Fix "disabling already-disabled device"
>> warning
>> 
>> From: Michele Baldessari <michele@acksyn.org>
>> Date: Thu, 30 Jan 2014 10:51:04 +0000
>> 
>> > In https://bugzilla.redhat.com/show_bug.cgi?id=994438 and
>> > https://bugzilla.redhat.com/show_bug.cgi?id=970480  we received
>> > different reports of e100 throwing the following
>> > warning:
>>  ...
>> > This patch removes pci_disable_device() from __e100_shutdown().
>> > pci_clear_master() is enough.
>> >
>> > Signed-off-by: Michele Baldessari <michele@acksyn.org>
>> > Tested-by: Mark Harig <idirectscm@aim.com>
> 
> Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
> 
> Sorry if it's a duplicate, one I sent out earlier did not seem to hit netdev.

I think this patch was posted twice, once without netdev properly
CC:'d and you replied to that copy.

Thanks Aaron, I'll apply this.
