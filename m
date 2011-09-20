From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: unicast hash in ixgbe and ixgbevf
Date: Tue, 20 Sep 2011 09:51:08 -0700
Message-ID: <43F901BD926A4E43B106BF17856F0755019C22B12F@orsmsx508.amr.corp.intel.com>
References: <4E747E5B.4050207@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "frog1120@gmail.com" <frog1120@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:8555 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751790Ab1ITQvS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2011 12:51:18 -0400
In-Reply-To: <4E747E5B.4050207@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of J.Hwan.Kim
> Sent: Saturday, September 17, 2011 4:03 AM
> To: netdev@vger.kernel.org
> Subject: unicast hash in ixgbe and ixgbevf
> 
> Hi, everyone
> 
> I'm using intel ixgbe and ixgbevf driver and SR-IOV option.
> 
> Is there any method for distributing the random IP packet stream
> into several VF queues evenly?
> 
> For example, for each 4 VF queues,
> can each a quarter of the IP stream be distributed to each 4 VF queues?
> 
> I checked the PFUTA register and tested it, but as far as I know,
> with the 4K bit hash table, the stream is directed to queues
> of which ROPE bit is set.
> So, the stream is duplicated to the queues of which ROPE bit is set.
> That is not what I want to do.
> 
> How can I distribute the random IP packets to several VF queues
> without duplicating?
[Greg Rose] 

Distribution of packets to different queues based upon IP address requires RSS which is not supported in our SR-IOV functions at this time.

Also, on the Intel 82599 and X540 adapters the VFs only support single queue operation.  There are plans for multiple queue operation based upon RSS in future products, but there is not support for it now.

- Greg Rose
LAN Access Division
Intel Corp.
