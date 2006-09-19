From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 03/23] e100: Add debugging code for cb cleaning and csum
 failures.
Date: Tue, 19 Sep 2006 15:25:09 -0700
Message-ID: <45106E45.5060306@intel.com>
References: <20060919172623.4605.56860.stgit@gitlost.site> <20060919172838.4605.35958.stgit@gitlost.site> <45104094.30803@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:30228 "EHLO mga02.intel.com")
	by vger.kernel.org with ESMTP id S1751097AbWISW1d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 18:27:33 -0400
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <45104094.30803@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Kok, Auke wrote:
>> Refine cb cleaning debug printout and print out all cleaned cbs' 
>> status. Add
>> debug flag for EEPROM csum failures that were overridden by the user.
>>
>> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
>> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> 
> ACK patch, NAK description:  tainting is far more than a debug flag.

For now I'll drop the taint flag from this patch until a better one comes up.

Cheers,

Auke
