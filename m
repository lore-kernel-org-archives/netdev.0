From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 04/23] e100: rework WoL and shutdown handling
Date: Tue, 19 Sep 2006 14:38:42 -0700
Message-ID: <45106362.3050604@intel.com>
References: <20060919172623.4605.56860.stgit@gitlost.site> <20060919172840.4605.33452.stgit@gitlost.site> <451040C2.5030005@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:26431 "EHLO mga01.intel.com")
	by vger.kernel.org with ESMTP id S1752086AbWISVmA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 17:42:00 -0400
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <451040C2.5030005@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Kok, Auke wrote:
>> Unify our shutdown/suspend/resume code and make it similar to e1000:
>> e1000_shutdown now calls suspend which does the exact same thing on
>> shutdown except saving PCI config state on suspend. WoL setup code
>> is now also more simple and works even when CONFIG_PM is not set, which
>> was previously broken.
>>
>> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> 
> Why does e100_suspend() need to exist even when CONFIG_PM is disabled?
> 
> WoL is fundamentally power management.

okay, I'll fix this for e1000 as well, where we have the same code flow.

Thanks.

Auke
