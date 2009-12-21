From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [RFC PATCH v2 01/12] ixgbevf: Macros, data structures, useful
	defines and registers
Date: Mon, 21 Dec 2009 10:51:08 -0800
Message-ID: <43F901BD926A4E43B106BF17856F07559A25893E@orsmsx508.amr.corp.intel.com>
References: <20091218225043.10698.58897.stgit@localhost.localdomain>
 <1261420702.2782.3.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: Ben Hutchings <bhutchings@solarflare.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:54891 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752216AbZLUSvN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Dec 2009 13:51:13 -0500
In-Reply-To: <1261420702.2782.3.camel@achroite.uk.solarflarecom.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Ben Hutchings [mailto:bhutchings@solarflare.com]
>Sent: Monday, December 21, 2009 10:38 AM
>To: Kirsher, Jeffrey T
>Cc: netdev@vger.kernel.org; gospo@redhat.com; Rose, Gregory V
>Subject: Re: [RFC PATCH v2 01/12] ixgbevf: Macros, data structures,
>useful defines and registers
>
>On Fri, 2009-12-18 at 14:51 -0800, Jeff Kirsher wrote:
>> From: Greg Rose <gregory.v.rose@intel.com>
>>
>> These two headers define the commonly used macros, data structures,
>> register bits and register offsets used by the ixgbevf driver on the
>> 82599 virtual function device
>>
>[...]
>> diff --git a/drivers/net/ixgbevf/defines.h
>b/drivers/net/ixgbevf/defines.h
>> new file mode 100644
>> index 0000000..b111771
>> --- /dev/null
>> +++ b/drivers/net/ixgbevf/defines.h
>[...]
>> +/* Check whether address is multicast.  This is little-endian
>specific check.*/
>> +#define IXGBE_IS_MULTICAST(Address) \
>> +	(bool)(((u8 *)(Address))[0] & ((u8)0x01))
>> +
>> +/* Check whether an address is broadcast. */
>> +#define IXGBE_IS_BROADCAST(Address)              \
>> +	((((u8 *)(Address))[0] == ((u8)0xFF)) && \
>> +	 (((u8 *)(Address))[1] == ((u8)0xFF)))
>[...]
>
>Why not use is_multicast_ether_addr() and  is_broadcast_ether_addr()?

This driver was derived from the ixgbe driver and I just copied and pasted those macros from drivers/net/ixgbe/ixgbe_type.h.  We (Intel/LAD) should probably post a patch to fix up both of these at some point.  We'll discuss this amongst ourselves and a patch should be forthcoming, though it may be outside the context of this series of patches.

- Greg


