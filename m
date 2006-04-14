From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 00/10] e1000: Driver fixes and update to 7.0.38-k2
Date: Fri, 14 Apr 2006 12:32:40 -0700
Message-ID: <443FF8D8.4050804@intel.com>
References: <20060414183423.3461.32772.stgit@gitlost.site> <443FF1A1.4000204@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Miller, David" <davem@davemloft.net>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kirsher, Jeff" <Jeffrey.t.kirsher@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr18.intel.com ([134.134.136.17]:8680 "EHLO
	orsfmr003.jf.intel.com") by vger.kernel.org with ESMTP
	id S1751429AbWDNTeN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Apr 2006 15:34:13 -0400
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <443FF1A1.4000204@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Kok, Auke wrote:
>> 01/10: [FIX] Remove PM warning DPRINTKs breaking 2.4.x kernels
>> 02/10: [FIX] Esb2 wol link cycle bug and uninitialized registers
>> 03/10: [PATCH] De-inline functions to benefit from compiler smartness
>> 04/10: [PATCH] Made an adapter struct variable into a local (txb2b)
>> 05/10: [PATCH] Update truesize with the length of the packet for
>>                       packet split
>> 06/10: [PATCH] Dead variable cleanup
>> 07/10: [PATCH] Buffer optimizations for small MTU
>> 08/10: [PATCH] implement more efficient tx queue locking
>> 09/10: [DOC] Version bump, contact fix, year string change
>> 10/10: [MAINTAINERS] {e100{,0},ixgb}: Add Auke Kok as new patch 
>> maintainer
> 
> These 10 patches look OK, but since the current kernel version is 
> 2.6.17-rc1, that means we are in "bug fix only" mode right now.
> 
> Should I (a) apply these all to netdev2-.6.git#upstream, queueing them 
> for 2.6.18, or (b) let you split the submission into two parts, bug 
> fixes only and everything else?

jeff,

The two fixes are for low-impact bugs with workarounds, not justifying 
applying them to 2.6.17-rc1 or stable@.

Please apply to netdev-2.6.git#upstream and queue them for 2.6.18. (a).

Cheers,

Auke
