From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH 1/6] virtio: wrap find_vqs
Date: Fri, 31 Mar 2017 12:04:55 +0800
Message-ID: <c388e4fd-2956-8894-31ec-31fe8b01e49f@redhat.com>
References: <1490820507-8005-1-git-send-email-mst@redhat.com>
 <1490820507-8005-2-git-send-email-mst@redhat.com>
 <72f533a2-482d-1956-b0fe-254e273e1818@redhat.com>
 <20170330173146-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org,
        John Fastabend <john.fastabend@gmail.com>,
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
        netdev@vger.kerne
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47372 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751012AbdCaEFc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 31 Mar 2017 00:05:32 -0400
In-Reply-To: <20170330173146-mutt-send-email-mst@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017年03月30日 22:32, Michael S. Tsirkin wrote:
> On Thu, Mar 30, 2017 at 02:00:08PM +0800, Jason Wang wrote:
>>
>> On 2017年03月30日 04:48, Michael S. Tsirkin wrote:
>>> We are going to add more parameters to find_vqs, let's wrap the call so
>>> we don't need to tweak all drivers every time.
>>>
>>> Signed-off-by: Michael S. Tsirkin<mst@redhat.com>
>>> ---
>> A quick glance and it looks ok, but what the benefit of this series, is it
>> required by other changes?
>>
>> Thanks
> Yes - to avoid touching all devices when doing the rest of
> the patchset.

Maybe I'm not clear. I mean the benefit of this series not this single 
patch. I guess it may be used by you proposal that avoid reset when set 
XDP? If yes, do we really want to drop some packets after XDP is set?

Thanks
