From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] virtio: don't set VIRTIO_NET_HDR_F_DATA_VALID on xmit
Date: Wed, 18 Jan 2017 15:07:11 +0300
Message-ID: <ecc7cc21-9e46-9cee-e9bc-bb29dfd6b06a@cogentembedded.com>
References: <20170117181351.98291-1-rolf.neugebauer@docker.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, davem@davemloft.net, jasowang@redhat.com,
        rppt@linux.vnet.ibm.com
To: Rolf Neugebauer <rolf.neugebauer@docker.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f52.google.com ([209.85.215.52]:33983 "EHLO
        mail-lf0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751600AbdARMNd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 07:13:33 -0500
Received: by mail-lf0-f52.google.com with SMTP id v186so9730767lfa.1
        for <netdev@vger.kernel.org>; Wed, 18 Jan 2017 04:13:32 -0800 (PST)
In-Reply-To: <20170117181351.98291-1-rolf.neugebauer@docker.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 1/17/2017 9:13 PM, Rolf Neugebauer wrote:

> This patch part reverts fd2a0437dc33 and e858fae2b0b8 which introduced a

    You also need to specify the patch summary lines enclosed in ("").

> subtle change in how the virtio_net flags are derived from the SKBs
> ip_summed field.
>
> With the above commits, the flags are set to VIRTIO_NET_HDR_F_DATA_VALID
> when ip_summed == CHECKSUM_UNNECESSARY, thus treating it differently to
> ip_summed == CHECKSUM_NONE, which should be the same.
>
> Further, the virtio spec 1.0 / CS04 explicitly says that
> VIRTIO_NET_HDR_F_DATA_VALID must not be set by the driver.
>
> Signed-off-by: Rolf Neugebauer <rolf.neugebauer@docker.com>
[...]

MBR, Sergei
