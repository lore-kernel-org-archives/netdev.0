From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [E1000-devel] e1000: ethtool -p + cable pull = system wedges
 hard
Date: Tue, 15 Aug 2006 20:01:41 -0700
Message-ID: <44E28A95.9080802@intel.com>
References: <200608160037.k7G0btZt002839@death.nxdomain.ibm.com> <44E26EE7.3000100@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:26481 "EHLO
	fmsmga101-1.fm.intel.com") by vger.kernel.org with ESMTP
	id S1750851AbWHPDDF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 23:03:05 -0400
To: Auke Kok <auke-jan.h.kok@intel.com>
In-Reply-To: <44E26EE7.3000100@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> Jay Vosburgh wrote:
>> 	Running both 2.6.17.6 plus the e1000 7.2.7 from sourceforge, or
>> the e1000 in netdev-2.6#upstream (7.1.9-k4).
>>
>> 	Starting up "ethtool -p ethX" then unplugging the cable
>> connected to the identified port is causing my system to completely
>> freeze; even sysrq is unresponsive.  I'm running on a 2-way x86 box,
>> with an 82545GM.
>>
>> 	Is this by any chance a known problem?
> 
> not at all.

One of my brain halves (the third one ;)) poked me and told me that it *is* a 
known issue. Not good. Apparently as early as kernel 2.5.50 a change was 
introduced that causes this. I am unsure what exactly caused it and I assume it 
is generic (other nic's might also suffer). The issue is documented in our 
standalone driver documentation. Not sure what to do with this.

Auke
