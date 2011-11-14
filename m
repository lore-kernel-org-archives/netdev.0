From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC PATCH net-next] enable virtio_net to return bus_info in
 ethtool -i consistent with emulated NICs
Date: Mon, 14 Nov 2011 14:40:18 -0800
Message-ID: <4EC198D2.9050802@hp.com>
References: <20111114215241.5B8BF2900307@tardy> <1321309800.2827.22.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <raj@tardy.cup.hp.com>, netdev@vger.kernel.org,
	Rusty Russell <rusty@rustcorp.com.au>,
	Michael Tsirkin <mst@redhat.com>,
	virtualization@lists.linux-foundation.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:19680 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756555Ab1KNWkU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 17:40:20 -0500
In-Reply-To: <1321309800.2827.22.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/14/2011 02:30 PM, Ben Hutchings wrote:
> On Mon, 2011-11-14 at 13:52 -0800, Rick Jones wrote:
>> From: Rick Jones<rick.jones2@hp.com>
>>
>> Add a new .bus_name to virtio_config_ops then modify virtio_net to
>> call through to it in an ethtool .get_drvinfo routine to report
>> bus_info in ethtool -i output which is consistent with other
>> emulated NICs and the output of lspci.
> [...]
>> diff --git a/drivers/lguest/lguest_device.c b/drivers/lguest/lguest_device.c
>> index 0dc30ff..3724d45 100644
>> --- a/drivers/lguest/lguest_device.c
>> +++ b/drivers/lguest/lguest_device.c
>> @@ -381,6 +381,11 @@ error:
>>   	return PTR_ERR(vqs[i]);
>>   }
>>
>> +static const char *lg_bus_name(struct virtio_device *vdev)
>> +{
>> +	return "Not Implemented";
>> +}
> [...]
>> +static const char *kvm_bus_name(struct virtio_device *vdev)
>> +{
>> +	return "Not Implemented";
>> +}
> [...]
>
> Please use the existing 'not implemented' value, which is the empty
> string.

Will do.

thanks,

rick
