From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH v6 38/46] tun: drop most type defines
Date: Fri, 28 Nov 2014 08:17:48 +0008
Message-ID: <1417162188.5822.1@smtp.corp.redhat.com>
References: <1417118789-18231-1-git-send-email-mst@redhat.com>
	<1417118789-18231-39-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Cc: linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	cornelia.huck@de.ibm.com, rusty@au1.ibm.com, nab@linux-iscsi.org,
	pbonzini@redhat.com, thuth@linux.vnet.ibm.com,
	dahi@linux.vnet.ibm.com, Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>,
	Tom Herbert <therbert@google.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	Masatake YAMATO <yamato@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Xi Wang <xii@google.com>, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45644 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751196AbaK1IKU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Nov 2014 03:10:20 -0500
In-Reply-To: <1417118789-18231-39-git-send-email-mst@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Fri, Nov 28, 2014 at 4:11 AM, Michael S. Tsirkin <mst@redhat.com> 
wrote:
> It's just as easy to use IFF_ flags directly,
> there's no point in adding our own defines.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> ---
>  drivers/net/tun.c | 62 
> +++++++++++++++++++++++++------------------------------
>  1 file changed, 28 insertions(+), 34 deletions(-)
> 
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c

Patch looks fine, but I don't see the reason that why not squash patch 
37
into this.

[..]
