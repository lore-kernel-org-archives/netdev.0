From: Tariq Toukan <ttoukan.linux@gmail.com>
Subject: Re: [PATCH net-next 8/8] net/mlx5e: XDP TX xmit more
Date: Tue, 20 Sep 2016 11:19:46 +0300
Message-ID: <0e732cab-ed54-5e09-569b-f75258e98ad4@gmail.com>
References: <1474293539-2595-1-git-send-email-tariqt@mellanox.com>
 <1474293539-2595-9-git-send-email-tariqt@mellanox.com>
 <20160920094629.12e78a85@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Eran Ben Elisha <eranbe@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Rana Shahout <ranas@mellanox.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>,
        Tariq Toukan <tariqt@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36662 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751211AbcITITu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 04:19:50 -0400
Received: by mail-wm0-f65.google.com with SMTP id b184so2021080wma.3
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 01:19:50 -0700 (PDT)
In-Reply-To: <20160920094629.12e78a85@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jesper,

On 20/09/2016 10:46 AM, Jesper Dangaard Brouer wrote:
> On Mon, 19 Sep 2016 16:58:59 +0300
> Tariq Toukan <tariqt@mellanox.com> wrote:
>
>> From: Saeed Mahameed <saeedm@mellanox.com>
>>
>> Previously we rang XDP SQ doorbell on every forwarded XDP packet.
>>
>> Here we introduce a xmit more like mechanism that will queue up more
>> than one packet into SQ (up to RX napi budget) w/o notifying the hardware.
>>
>> Once RX napi budget is consumed and we exit napi RX loop, we will
>> flush (doorbell) all XDP looped packets in case there are such.
> I've already raised strong concerns with this approach on the RFC
> patchset.  Of not really taking advantage of RX bulking.
> Please do not ignore this!
Sure. Your approach can fit with our plans to split the RX completion 
poll loop into several stages.
I will try it when we get there.
>
> If you can promise, that we/you will also try to other approach I'm
> suggesting, then I'm fine with this patch.
>
Thanks.
