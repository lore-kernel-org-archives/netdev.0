From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH RFC 1/2] tun: don't require serialization lock on tx
Date: Wed, 13 Apr 2016 17:26:01 +0300
Message-ID: <570E56F9.7030200@cogentembedded.com>
References: <cover.1460393493.git.pabeni@redhat.com>
 <425e8f69ffd8fe315ef9d3cc678519c7060fb2e0.1460393493.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Greg Kurz <gkurz@linux.vnet.ibm.com>,
	Jason Wang <jasowang@redhat.com>
To: Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f48.google.com ([209.85.215.48]:34419 "EHLO
	mail-lf0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964849AbcDMO0F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2016 10:26:05 -0400
Received: by mail-lf0-f48.google.com with SMTP id j11so72059295lfb.1
        for <netdev@vger.kernel.org>; Wed, 13 Apr 2016 07:26:04 -0700 (PDT)
In-Reply-To: <425e8f69ffd8fe315ef9d3cc678519c7060fb2e0.1460393493.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 4/13/2016 12:04 PM, Paolo Abeni wrote:

> The current tun_net_xmit() implementation don't need any external
> lock since it relay on rcu protection for the tun data structure

    s/relay/relies/?

> and on socket queue lock for skb queuing.
>
> This patch set the NETIF_F_LLTX feature bit in the tun device, so
> that on xmit, in absence of qdisc, no serialization lock is acquired
> by the caller.
>
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
[...]

MBR, Sergei
