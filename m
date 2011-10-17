From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 2/6] igb: Check if subordinate VFs are assigned to
 virtual machines
Date: Mon, 17 Oct 2011 16:49:23 -0400 (EDT)
Message-ID: <20111017.164923.1338037749342409936.davem@davemloft.net>
References: <1318851161-30163-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1318851161-30163-3-git-send-email-jeffrey.t.kirsher@intel.com>
	<1318852447.2960.50.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregory.v.rose@intel.com, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com, konrad.wilk@oracle.com, benve@cisco.com,
	sathya.perla@emulex.com, dm@chelsio.com, jdmason@kudzu.us,
	james.smart@emulex.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52528 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753990Ab1JQUti (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2011 16:49:38 -0400
In-Reply-To: <1318852447.2960.50.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 17 Oct 2011 04:54:06 -0700

> On Mon, 2011-10-17 at 04:32 -0700, Kirsher, Jeffrey T wrote:
>> From: Greg Rose <gregory.v.rose@intel.com>
>> 
>> Kvm and the Xen pci-back driver will set a flag in the virtual
>> function
>> pci device dev_flags when the VF is assigned to a guest VM.  Before
>> destroying subordinate VFs check to see if the flag is set and if so
>> skip the call to pci_disable_sriov() to avoid system crashes.
>> 
>> Copy the maintainer for the Xen pci-back driver.  Also CC'ing
>> maintainers of all drivers found to call pci_disable_sriov().
>> 
>> Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
>> Cc: Christian Benvenuti <benve@cisco.com>
>> Cc: Sathya Perla <sathya.perla@emulex.com>
>> Cc: Dimitris Michailidis <dm@chelsio.com>
>> Cc: Jon Mason <jdmason@kudzu.us>
>> Cc: James Smart <james.smart@emulex.com>
>> 
>> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com> 
> 
> Dave- please do not pull this patch (or the series).  There is an issue
> with this patch.

Ok.
