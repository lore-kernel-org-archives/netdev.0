From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 04/23] e100: rework WoL and shutdown handling
Date: Tue, 19 Sep 2006 16:30:38 -0400
Message-ID: <4510536E.4000209@pobox.com>
References: <20060919172623.4605.56860.stgit@gitlost.site> <20060919172840.4605.33452.stgit@gitlost.site> <451040C2.5030005@pobox.com> <45105249.1070200@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:42430 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751128AbWISUap (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 16:30:45 -0400
To: Auke Kok <auke-jan.h.kok@intel.com>
In-Reply-To: <45105249.1070200@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> Jeff Garzik wrote:
>> Kok, Auke wrote:
>>> Unify our shutdown/suspend/resume code and make it similar to e1000:
>>> e1000_shutdown now calls suspend which does the exact same thing on
>>> shutdown except saving PCI config state on suspend. WoL setup code
>>> is now also more simple and works even when CONFIG_PM is not set, which
>>> was previously broken.
>>>
>>> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
>>
>> Why does e100_suspend() need to exist even when CONFIG_PM is disabled?
>>
>> WoL is fundamentally power management.
> 
> same as e1000_suspend: we're consolidating shutdown code making 2 
> different codepaths exactly the same.
> 
> e100_shutdown calls e100_suspend() in case of a normal powerdown.

OK, well you don't need to list it in the pci_driver struct then...


