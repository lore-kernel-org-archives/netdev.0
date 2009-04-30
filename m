From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH] virtio: add missing include to virtio_net.h
Date: Wed, 29 Apr 2009 19:20:38 -0600
Message-ID: <fa686aa40904291820q9019708oaa737c6d8f65ca02@mail.gmail.com>
References: <20090428154654.19053.92829.stgit@localhost.localdomain>
	<20090429.174943.133929746.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	rusty@rustcorp.com.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.31]:46640 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751524AbZD3BU6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 21:20:58 -0400
In-Reply-To: <20090429.174943.133929746.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 29, 2009 at 6:49 PM, David Miller <davem@davemloft.net> wro=
te:
> From: Grant Likely <grant.likely@secretlab.ca>
> Date: Tue, 28 Apr 2009 09:46:54 -0600
>
> [ Grant, please CC: netdev on networking patches, thanks. ]

Oops, sorry about that; I had in my head "virtio" and it didn't even
occur to me that it was also netdev.  :-)

g.

>
>> virtio_net.h uses the macro ETH_ALEN which is defined in linux/if_et=
her.h.
>> Discovered when hacking on virtio-over-pci patches.
>>
>> Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
>
> Rusty, ACK?
>
> I haven't been able to get responses from Rusty on virtio net
> patches, so if he doesn't start responding soon I'm going to
> integrates the fixes I've seen lately as they all look
> reasonable to me.
>
>> ---
>>
>> =A0include/linux/virtio_net.h | =A0 =A01 +
>> =A01 files changed, 1 insertions(+), 0 deletions(-)
>>
>>
>> diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
>> index 242348b..cec79ad 100644
>> --- a/include/linux/virtio_net.h
>> +++ b/include/linux/virtio_net.h
>> @@ -4,6 +4,7 @@
>> =A0 * compatible drivers/servers. */
>> =A0#include <linux/types.h>
>> =A0#include <linux/virtio_config.h>
>> +#include <linux/if_ether.h>
>>
>> =A0/* The ID for virtio_net */
>> =A0#define VIRTIO_ID_NET =A0 =A0 =A0 =A01
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kern=
el" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at =A0http://www.tux.org/lkml/
>



--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
