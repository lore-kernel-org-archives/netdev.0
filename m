From: Jason Wang <jasowang@redhat.com>
Subject: Re: The ubufs->refcount maybe be subtracted twice when tun_get_user
 failed
Date: Wed, 30 Nov 2016 13:24:04 +0800
Message-ID: <9e393b35-2265-fad9-34be-08658ff3c512@redhat.com>
References: <34EFBCA9F01B0748BEB6B629CE643AE60B0A553E@szxeml561-mbx.china.huawei.com>
 <30e4c704-70b4-d318-68bd-742eb5f9bfc7@redhat.com>
 <34EFBCA9F01B0748BEB6B629CE643AE60B0A5826@szxeml561-mbx.china.huawei.com>
 <fad5d47a-96ee-1afc-b10c-cb2a6d5dc784@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: caihe <caihe@huawei.com>
To: wangyunjian <wangyunjian@huawei.com>,
        "mst@redhat.com" <mst@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56582 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750825AbcK3FYI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 30 Nov 2016 00:24:08 -0500
In-Reply-To: <fad5d47a-96ee-1afc-b10c-cb2a6d5dc784@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2016年11月30日 10:53, Jason Wang wrote:
>
>
> On 2016年11月29日 21:27, wangyunjian wrote:
>> Sorry, I didn't describe it clearly. In fact, the second subtraction 
>> happens in the function handle_tx,
>> when tun_get_user fails and zcopy_used is ture. Fllowing the steps:
>
> I get your meaning. Thanks for the reporting. Will post patches (since 
> macvtap has similar issue).

Posted, appreciate if you can have a test on them.

Thanks
