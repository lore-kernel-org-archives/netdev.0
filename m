From: Ben Greear <greearb@candelatech.com>
Subject: Re: e100 firmware in 2.6.29-rc7?
Date: Mon, 16 Mar 2009 13:05:41 -0700
Message-ID: <49BEB115.4050303@candelatech.com>
References: <49BABF1F.9080909@candelatech.com>	 <alpine.WNT.2.00.0903161143180.5116@jbrandeb-desk1.amr.corp.intel.com>	 <49BEA4E6.1000206@candelatech.com> <1237231540.3106.9.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	NetDev <netdev@vger.kernel.org>, dwmw2@infradead.org,
	e1000-devel@lists.sourceforge.net
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:48966 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753118AbZCPUGB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2009 16:06:01 -0400
In-Reply-To: <1237231540.3106.9.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:

>> The config & dmesg is attached.  Some of the options are for patches we've
>> added, and we even have a small patch in the e100 (but have had it there
>> for years, so probably un-related to this).  Still, I will not complain
>> if you decide to ignore the report.
> [...]
> 
> Your config has CONFIG_E100=m, but CONFIG_FIRMWARE_IN_KERNEL only
> applies to firmware used by non-modular drivers.  The assumption is that
> once userland is capable of loading modules it is also capable of
> loading firmware.

Well, that's an annoyance.  Would it be that hard to allow modular drivers
to compile-in their FW as well?  It would be a nice option for
those of us trying to build portable pre-compiled kernels for various
distributions and distribution versions.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

