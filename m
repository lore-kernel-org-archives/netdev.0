From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 5/5] ixgbe: fixup warning regarding max_vfs parameter
Date: Thu, 13 Feb 2014 15:20:38 -0500 (EST)
Message-ID: <20140213.152038.941752640893223419.davem@davemloft.net>
References: <1392278450-27062-1-git-send-email-aaron.f.brown@intel.com>
	<1392278450-27062-6-git-send-email-aaron.f.brown@intel.com>
	<1392321692.15615.48.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: aaron.f.brown@intel.com, jacob.e.keller@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49514 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751001AbaBMUUl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 15:20:41 -0500
In-Reply-To: <1392321692.15615.48.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Thu, 13 Feb 2014 20:01:32 +0000

> On Thu, 2014-02-13 at 00:00 -0800, Aaron Brown wrote:
>> From: Jacob Keller <jacob.e.keller@intel.com>
>> 
>> The max_vfs parameter for ixgbe is deprecated in favor of using the
>> sysfs sriov_numvfs field to assign VFs as needed, instead of fixing the
>> value at module load time. The current message only indicates that you
>> should use this, without adequately explaining how to do so.
> 
> I don't think the kernel log is the correct place to put documentation.
> A reference alone should be enough.
> 
> [...]
>> +               e_dev_warn("See 'Documentation/PCI/pci-iov-howto.txt for more information.\n");
> [...]
> 
> This doesn't seem very helpful to non-developers.  You could instead
> give the URL:
> 
> https://www.kernel.org/doc/Documentation/PCI/pci-iov-howto.txt

I even think this is not desirable.  The kernel log isn't supposed to be
a hyper-linked "all the information you could possibly need" repository
for every interesting situation the kernel encounters.

Just say plainly what the problem is, people need a certainly level of
understanding to interpret kernel messages properly.
