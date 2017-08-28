From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [Intel-wired-lan] [PATCH] e1000e: apply burst mode settings only
 on default
Date: Mon, 28 Aug 2017 09:25:46 -0700
Message-ID: <CAKgT0UctVUqAU7XAoiDOm8dSB20dFT+75qDpn2u4kyJDZ-Usyw@mail.gmail.com>
References: <20170825150626.2843-1-willemdebruijn.kernel@gmail.com> <291b863f-552e-2f3b-f658-e812d0848949@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
        <"jeffrey.t.kirsher@intel.com, alexander.h.duyck@intel.com, raanan.avargil@intel.com, dima.ruinskiy"@intel.com>,
        Netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>
To: "Neftin, Sasha" <sasha.neftin@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:38470 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751203AbdH1QZs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 12:25:48 -0400
Received: by mail-qk0-f195.google.com with SMTP id o63so845113qkb.5
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 09:25:47 -0700 (PDT)
In-Reply-To: <291b863f-552e-2f3b-f658-e812d0848949@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 27, 2017 at 1:30 AM, Neftin, Sasha <sasha.neftin@intel.com> wrote:
> On 8/25/2017 18:06, Willem de Bruijn wrote:
>>
>> From: Willem de Bruijn <willemb@google.com>
>>
>> Devices that support FLAG2_DMA_BURST have different default values
>> for RDTR and RADV. Apply burst mode default settings only when no
>> explicit value was passed at module load.
>>
>> The RDTR default is zero. If the module is loaded for low latency
>> operation with RxIntDelay=0, do not override this value with a burst
>> default of 32.
>>
>> Move the decision to apply burst values earlier, where explicitly
>> initialized module variables can be distinguished from defaults.
>>
>> Signed-off-by: Willem de Bruijn <willemb@google.com>
>
> This patch looks good for me, but I would like hear second opinion.

This code is an improvement over what was already there. I am good with this.

Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>
