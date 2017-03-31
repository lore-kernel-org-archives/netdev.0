From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH V2 net-next 5/7] tun: support receiving skb through
 msg_control
Date: Fri, 31 Mar 2017 12:10:11 +0800
Message-ID: <571168f4-981d-4f2a-4211-9b42c696ff52@redhat.com>
References: <1490858550-7763-1-git-send-email-jasowang@redhat.com>
 <1490858550-7763-6-git-send-email-jasowang@redhat.com>
 <20170330180414-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170330180414-mutt-send-email-mst@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2017年03月30日 23:06, Michael S. Tsirkin wrote:
> On Thu, Mar 30, 2017 at 03:22:28PM +0800, Jason Wang wrote:
>> This patch makes tun_recvmsg() can receive from skb from its caller
>> through msg_control. Vhost_net will be the first user.
>>
>> Signed-off-by: Jason Wang<jasowang@redhat.com>
> Do we need to bother with tun? I didn't realize one
> can even use that with vhost. What would be the point of
> all the virtio header stuff dealing with checksums etc?
>
> Even if you see a use-case is it worth optimizing?
>
>

It's for tap in fact. I use "tun" just because we have already had a 
tap.c which is used by macvtap.

Thanks
