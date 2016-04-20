From: Denys Vlasenko <dvlasenk@redhat.com>
Subject: Re: [PATCH 1/3] e1000e: e1000e_cyclecounter_read(): incvalue is 32
 bits, not 64
Date: Wed, 20 Apr 2016 17:43:05 +0200
Message-ID: <5717A389.5070902@redhat.com>
References: <1461069286-31946-1-git-send-email-dvlasenk@redhat.com> <1461099434.2923.6.camel@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34027 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751973AbcDTPnH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Apr 2016 11:43:07 -0400
In-Reply-To: <1461099434.2923.6.camel@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/19/2016 10:57 PM, Jeff Kirsher wrote:
> On Tue, 2016-04-19 at 14:34 +0200, Denys Vlasenko wrote:
>> "incvalue" variable holds a result of "er32(TIMINCA) &
>> E1000_TIMINCA_INCVALUE_MASK"
>> and used in "do_div(temp, incvalue)" as a divisor.
>>
>> Thus, "u64 incvalue" declaration is probably a mistake.
>> Even though it seems to be a harmless one, let's fix it.
>>
>> Signed-off-by: Denys Vlasenko <dvlasenk@redhat.com>
>> CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> CC: Jesse Brandeburg <jesse.brandeburg@intel.com>
>> CC: Shannon Nelson <shannon.nelson@intel.com>
>> CC: Carolyn Wyborny <carolyn.wyborny@intel.com>
>> CC: Don Skidmore <donald.c.skidmore@intel.com>
>> CC: Bruce Allan <bruce.w.allan@intel.com>
>> CC: John Ronciak <john.ronciak@intel.com>
>> CC: Mitch Williams <mitch.a.williams@intel.com>
>> CC: David S. Miller <davem@davemloft.net>
>> CC: LKML <linux-kernel@vger.kernel.org>
>> CC: netdev@vger.kernel.org
>> ---
>>  drivers/net/ethernet/intel/e1000e/netdev.c | 3 ++-
>>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> First of all, trimmed down the recipient list since almost all of the
> reviewers you added have nothing to do with e1000e.

I took the list here, MAINTAINERS:

INTEL ETHERNET DRIVERS
M:      Jeff Kirsher <jeffrey.t.kirsher@intel.com>
R:      Jesse Brandeburg <jesse.brandeburg@intel.com>
R:      Shannon Nelson <shannon.nelson@intel.com>
R:      Carolyn Wyborny <carolyn.wyborny@intel.com>
R:      Don Skidmore <donald.c.skidmore@intel.com>
R:      Bruce Allan <bruce.w.allan@intel.com>
R:      John Ronciak <john.ronciak@intel.com>
R:      Mitch Williams <mitch.a.williams@intel.com>

No more specific information who's e1000e reviewer.
Sorry.
