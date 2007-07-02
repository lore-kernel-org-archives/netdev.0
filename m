From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [2.6 patch] the overdue eepro100 removal
Date: Mon, 02 Jul 2007 14:45:54 -0700
Message-ID: <46897212.30104@intel.com>
References: <20070701202139.GM10869@stusta.de> <46894BD5.9080609@tmr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@stusta.de>, jgarzik@pobox.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	saw@saw.sw.com.sg
To: Bill Davidsen <davidsen@tmr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:24236 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755629AbXGBVpz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jul 2007 17:45:55 -0400
In-Reply-To: <46894BD5.9080609@tmr.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bill Davidsen wrote:
> Adrian Bunk wrote:
>> This patch contains the overdue removal of the eepro100 driver.
>>
>> Signed-off-by: Adrian Bunk <bunk@stusta.de>
>>
> The hardware supported by this driver is still in use, thanks. It's 
> probably easier to leave the eepro100 driver in than find anyone who 
> wants to investigate why the other driver (e100? from memory) doesn't 
> work with some cards. As I recall this was suggested over a year ago and 
> it was decided to leave it in, all of the reasons for doing so still 
> seem valid. There really doesn't seem to be a benefit, it's not like 
> people are working night and day to support new cards for this chip.
> 

please see the thread "Re: [PATCH] fix e100 rx path on ARM (was [PATCH] e100 rx: 
or s and el bits)" which is discussing a fix for this issue and currently being 
worked.

eepro100 will *still* be removed once e100 is fixed to support those devices.

Moreover, we now also have a fix for the e100 IPMI issues on some tyan boards 
(patch coming this week!). That hopefully solves all e100 issues that are still 
open.

Auke
