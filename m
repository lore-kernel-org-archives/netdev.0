From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [RESEND PATCH] virtio-net: init link state correctly
Date: Mon, 8 Nov 2010 09:41:27 +1030
Message-ID: <201011080941.28190.rusty@rustcorp.com.au>
References: <20101105094718.19101.58898.stgit@dhcp-91-158.nay.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, markmc@redhat.com, kvm@vger.kernel.org,
	mst@redhat.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101105094718.19101.58898.stgit@dhcp-91-158.nay.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 5 Nov 2010 08:17:18 pm Jason Wang wrote:
> For device that supports VIRTIO_NET_F_STATUS, there's no need to
> assume the link is up and we need to call nerif_carrier_off() before
> querying device status, otherwise we may get wrong operstate after
> diver was loaded because the link watch event was not fired as
> expected.
> 
> For device that does not support VIRITO_NET_F_STATUS, we could not get
> its status through virtnet_update_status() and what we can only do is
> always assuming the link is up.
> 
> Acked-by: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Acked-by: Rusty Russell <rusty@rustcorp.com.au>

Thanks!
Rusty.
