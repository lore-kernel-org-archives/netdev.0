From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 0/6][pull request] Intel Wired LAN Driver Updates
Date: Mon, 17 Sep 2012 00:53:36 -0400 (EDT)
Message-ID: <20120917.005336.1153573955409483011.davem@davemloft.net>
References: <1346888106-25638-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1347570359.2219.96.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	matthew.vick@intel.com, bhutchings@solarflare.com,
	jacob.e.keller@intel.com, richardcochran@gmail.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53206 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751703Ab2IQExk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2012 00:53:40 -0400
In-Reply-To: <1347570359.2219.96.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 13 Sep 2012 14:05:59 -0700

> On Wed, 2012-09-05 at 16:35 -0700, Kirsher, Jeffrey T wrote:
>> This series contains updates to igb (specifically PTP code).
>> 
>> The following are changes since commit f6fe569fe056388166575af1cfaed0bcbc688305:
>>   Revert "usbnet: drop unneeded check for NULL"
>> and are available in the git repository at:
>>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master
>> 
>> Matthew Vick (6):
>>   igb: Tidy up wrapping for CONFIG_IGB_PTP.
>>   igb: Update PTP function names/variables and locations.
>>   igb: Correct PTP support query from ethtool.
>>   igb: Store the MAC address in the name in the PTP struct.
>>   igb: Prevent dropped Tx timestamps via work items and interrupts.
>>   igb: Add 1588 support to I210/I211.
 ...
> I see you have set this series to "Changes Requested" in patchworks, and
> I am assuming that is from the discussion that occurred on patch 04 of
> the series.  That discussion came to the conclusion that changes should
> happen in the PTP core, and that the patch is fine as is currently.
> 
> If there was something else you want changed, let me/Matthew know so
> that we can make the necessary changes.

Thanks for updating me on this, pulled and pushed out.
