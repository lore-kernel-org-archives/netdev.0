From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH 1/6] virtio: wrap find_vqs
Date: Thu, 30 Mar 2017 14:00:08 +0800
Message-ID: <72f533a2-482d-1956-b0fe-254e273e1818@redhat.com>
References: <1490820507-8005-1-git-send-email-mst@redhat.com>
 <1490820507-8005-2-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: John Fastabend <john.fastabend@gmail.com>,
        Arnd Bergmann <arnd@arndb.de>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Amit Shah <amit@kernel.org>, Gonglei <arei.gonglei@huawei.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>,
        David Airlie <airlied@linux.ie>,
        Gerd Hoffmann <kraxel@redhat.com>,
        Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>,
        Ohad Ben-Cohen <ohad@wizery.com>,
        Bjorn Andersson <bjorn.andersson@linaro.org>,
        "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
        "Martin K. Petersen" <martin.petersen@oracle.com>,
        Stefan Hajnoczi <stefanha@redhat.com>,
        virtualization@lists.linux-foundation.org,
        linux-crypto@vger.kernel.org, dri-devel@lists.freedesktop.org,
        netdev@vger.kernel.org, linux-remoteproc@vger.kernel.or
To: "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33420 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755264AbdC3GA2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 30 Mar 2017 02:00:28 -0400
In-Reply-To: <1490820507-8005-2-git-send-email-mst@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017年03月30日 04:48, Michael S. Tsirkin wrote:
> We are going to add more parameters to find_vqs, let's wrap the call so
> we don't need to tweak all drivers every time.
>
> Signed-off-by: Michael S. Tsirkin<mst@redhat.com>
> ---

A quick glance and it looks ok, but what the benefit of this series, is 
it required by other changes?

Thanks
