From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next RFC 5/5] vhost_net: basic tx virtqueue batched
 processing
Date: Thu, 28 Sep 2017 15:52:59 +0800
Message-ID: <1455d9db-3f2f-4139-8729-29fb03dd73aa@redhat.com>
References: <1506067355-5771-1-git-send-email-jasowang@redhat.com>
 <1506067355-5771-6-git-send-email-jasowang@redhat.com>
 <20170926222223-mutt-send-email-mst@kernel.org>
 <16ea7512-d770-21ef-edb6-3ada51f08592@redhat.com>
 <20170928011724-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kvm@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170928011724-mutt-send-email-mst@kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2017年09月28日 06:19, Michael S. Tsirkin wrote:
>
>>> 2. add new APIs and move the loop into vhost core
>>>      for more speedups
>> I don't see any advantages, looks like just need some e.g callbacks in this
>> case.
>>
>> Thanks
> IUC callbacks pretty much destroy the code cache locality advantages,
> IP is jumping around too much.

I may miss something, but we need net specific code anyway in this case?

Thanks
