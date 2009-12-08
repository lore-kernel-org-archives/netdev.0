From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [RFC PATCH 12/12] ixgbevf: Kconfig, Makefile and Documentation
Date: Tue, 8 Dec 2009 14:49:21 -0800
Message-ID: <43F901BD926A4E43B106BF17856F07558C0F4B7F@orsmsx508.amr.corp.intel.com>
References: <20091208221258.28373.16663.stgit@localhost.localdomain>
	<20091208221652.28373.22254.stgit@localhost.localdomain>
 <20091208144136.dff6ce84.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: Randy Dunlap <randy.dunlap@oracle.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:19358 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966793AbZLHWt0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2009 17:49:26 -0500
In-Reply-To: <20091208144136.dff6ce84.randy.dunlap@oracle.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Randy Dunlap [mailto:randy.dunlap@oracle.com]
>Sent: Tuesday, December 08, 2009 2:42 PM
>To: Kirsher, Jeffrey T
>Cc: netdev@vger.kernel.org; gospo@redhat.com; Rose, Gregory V
>Subject: Re: [RFC PATCH 12/12] ixgbevf: Kconfig, Makefile and
>Documentation
>
>> +The ixgbevf driver supports 82599-based virtual function devices that
>can only
>> +be activated on kernels with CONFIG_PCI_IOV enabled.
>> +
>> +The guest OS loading the ixgbevf driver must support MSI-X
>interrupts.
>
>Hi,
>
>Could the Kconfig language express some of these requirements, or
>am I confused between the host and the guest OS?
[Rose, Gregory V] 

The guest OS must also support MSI-X interrupts.  It is a requirement of our VF device to use MSI-X.

>
>
>> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
>> index 0bbd5ae..a484415 100644
>> --- a/drivers/net/Kconfig
>> +++ b/drivers/net/Kconfig
>> @@ -2614,6 +2614,27 @@ config IXGBE_DCB
>>
>>  	  If unsure, say N.
>>
>> +config IXGBEVF
>> +       tristate "Intel(R) 82599 Virtual Function Ethernet support"
>> +       depends on PCI
>
>	depends on PCI_IOV && PCI_MSI
>??
>
[Rose, Gregory V] 

The guest does not need to have IOV support configured to use the VF device but it does need MSI-X.  We'll incorporate this suggested change.

Thanks for your comments.

- Greg

