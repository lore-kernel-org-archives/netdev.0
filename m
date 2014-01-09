From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 3/7] ixgbe: Use static inlines instead of macros
Date: Thu, 09 Jan 2014 14:39:23 -0500 (EST)
Message-ID: <20140109.143923.437905458430188006.davem@davemloft.net>
References: <1389166847-3780-4-git-send-email-aaron.f.brown@intel.com>
	<CE14B815-C10B-4091-A608-6742117FBEF6@cumulusnetworks.com>
	<2C8FA848-3185-43BA-BDD7-955B0C7DD835@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfeldma@cumulusnetworks.com, aaron.f.brown@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: mark.d.rustad@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33265 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752543AbaAITjZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 14:39:25 -0500
In-Reply-To: <2C8FA848-3185-43BA-BDD7-955B0C7DD835@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Date: Thu, 9 Jan 2014 17:34:18 +0000

> On Jan 8, 2014, at 12:47 AM, Scott Feldman <sfeldma@cumulusnetworks.com> wrote:
> 
>> 
>> On Jan 7, 2014, at 11:40 PM, Aaron Brown <aaron.f.brown@intel.com> wrote:
>> 
>>> From: Mark Rustad <mark.d.rustad@intel.com>
>>> 
>>> -#define IXGBE_WRITE_REG(a, reg, value) writel((value), ((a)->hw_addr + (reg)))
>>> +static inline void IXGBE_WRITE_REG(struct ixgbe_hw *hw, u32 reg, u32 value)
>> 
>> Bummer, now you have a all-caps func name.
> 
> Agreed, but this is actually a fairly common condition among drivers that used to use macros. It isn't perfect, but at least it is moving in the right direction. I'd rather leave the case change for a later patch series that does only that or has some reason to touch all of the register access sites.
> 
> At least the new accessor I introduced is lower case. :-)

Please address this feedback, all caps function names are really not
appropriate.
