From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 17/21] e1000: add ich8lan core functions
Date: Tue, 27 Jun 2006 09:12:09 -0700
Message-ID: <44A158D9.6070601@intel.com>
References: <20060622051815.25497.89192.stgit@gitlost.site> <20060622052043.25497.85145.stgit@gitlost.site> <44A08F59.6030700@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>, netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:13075 "EHLO
	orsmga101-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S1161153AbWF0QNv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 12:13:51 -0400
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <44A08F59.6030700@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Kok, Auke wrote:
>> This implements the core new functions needed for ich8's internal
>> NIC. This includes:
>>
>> * ich8 specific read/write code
>> * flash/nvm access code
>> * software semaphore flag functions
>> * 10/100 PHY (fe - no gigabit speed) support for low-end versions
>> * A workaround for a powerdown sequence problem discovered that
>> affects a small number of motherboard.
>>
>> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
>> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
>> ---
>>
>>  drivers/net/e1000/e1000_hw.c    | 1000 
>> +++++++++++++++++++++++++++++++++++++++
>>  drivers/net/e1000/e1000_hw.h    |  386 +++++++++++++++
>>  drivers/net/e1000/e1000_osdep.h |   13 +
>>  3 files changed, 1392 insertions(+), 7 deletions(-)
> 
> If it takes this much code to support ICH8, it seems like a e1000-ich8.c 
> would be warranted...

that's work in progress - Jeb Cramer has been working on this for a while now 
but unfortunately it's not ready, and getting ich8 supported in a way that we 
know that doesn't introduce new bugs is more important. This patch adds tested 
and validated support for these chipsets that has been hammered by our test team.

We are planning (working) on cleaning it all up (including whitespace!) - but 
getting the ich8 support out is more important - people can buy the hardware 
today.

Cheers,

Auke
