From: Naresh Kumar Inna <naresh@chelsio.com>
Subject: Re: [PATCH 0/8] csiostor: Chelsio FCoE  offload driver submission
Date: Sat, 25 Aug 2012 00:34:35 +0530
Message-ID: <5037D043.7000302@chelsio.com>
References: <1345760873-12101-1-git-send-email-naresh@chelsio.com> <20120824.130406.1059160453285824849.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "JBottomley@parallels.com" <JBottomley@parallels.com>,
	"linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	Dimitrios Michailidis <dm@chelsio.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Chethan Seshadri <chethan@chelsio.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:2956 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758731Ab2HXTEy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 15:04:54 -0400
In-Reply-To: <20120824.130406.1059160453285824849.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/24/2012 10:34 PM, David Miller wrote:
> From: Naresh Kumar Inna <naresh@chelsio.com>
> Date: Fri, 24 Aug 2012 03:57:45 +0530
> 
>> This is the initial submission of the Chelsio FCoE offload driver (csiostor)
>> to the upstream kernel. This driver currently supports FCoE offload
>> functionality over Chelsio T4-based 10Gb Converged Network Adapters.
>>
>> The following patches contain the driver sources for csiostor driver and
>> updates to firmware/hardware header files shared between csiostor and
>> cxgb4 (Chelsio T4-based NIC driver). The csiostor driver is dependent on these
>> header updates. These patches have been generated against scsi 'misc' branch.
>>
>> csiostor is a low level SCSI driver that interfaces with PCI, SCSI midlayer and
>> FC transport subsystems. This driver claims the FCoE PCIe function on the
>> Chelsio Converged Network Adapter. It relies on firmware events for slow path
>> operations like discovery, thereby offloading session management. The driver
>> programs firmware via Work Request interfaces for fast path I/O offload
>> features.
> 
> You are going to have to get rid of these module parameters.
> 
> That have to do with things that are in no way specific to your device,
> and therefore should be configured using generic kernel facilities.
> 
> Using driver specific module parameters results in a poor user
> experience, because in order to make a configuration change the user
> has to know exactly what kind of device and driver is underneath,
> and then learn what the unique method is to make that configuration
> change.
> 
> If you use a generic facility, the user only needs to learn one way to
> make a configuration change, regardless of device type and driver.
> 

Hi Dave,

Thanks for reviewing. Is your comment with respect to any particular
module parameter[s] in this driver or all of them?

Regards,
Naresh.
