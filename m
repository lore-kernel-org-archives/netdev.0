From: Gerard Garcia <ggarcia@abra.uab.cat>
Subject: Re: [PATCH v2 1/1] VSOCK: remove more space available check filling
 TXvq
Date: Sat, 13 Aug 2016 11:55:49 +0200
Message-ID: <fa220f2f-9ec7-9cd2-b5ca-aa4333db2d0e@deic.uab.cat>
References: <20160810152434.14346-1-ggarcia@deic.uab.cat>
 <20160812.173115.1043123219898818778.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stefanha@redhat.com, mst@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34399 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751726AbcHMJzx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Aug 2016 05:55:53 -0400
Received: by mail-wm0-f68.google.com with SMTP id q128so1710685wma.1
        for <netdev@vger.kernel.org>; Sat, 13 Aug 2016 02:55:53 -0700 (PDT)
In-Reply-To: <20160812.173115.1043123219898818778.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/13/2016 02:31 AM, David Miller wrote:
> From: ggarcia@abra.uab.cat
> Date: Wed, 10 Aug 2016 17:24:34 +0200
>
>> From: Gerard Garcia <ggarcia@deic.uab.cat>
>>
>> Remove unnecessary use of enable/disable callback notifications
>> and the incorrect more space available check.
>>
>> The virtio_transport_tx_work handles when the TX virtqueue
>> has more buffers available.
>>
>> Signed-off-by: Gerard Garcia <ggarcia@deic.uab.cat>
>> Acked-by: Stefan Hajnoczi <stefanha@redhat.com>
>
> This does not apply cleanly to the current net GIT tree.
>

I'm sorry, I should have said that it applies over the mst vhost tree.
