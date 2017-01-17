From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v2 net-next] net:add one common config ARCH_WANT_RELAX_ORDER
 to support relax ordering.
Date: Tue, 17 Jan 2017 11:27:36 -0800
Message-ID: <CAKgT0UcXFk3_LfsWyVeh6X_91mfVLJt3VRBSY_2r+ebjxfW7iQ@mail.gmail.com>
References: <1483939954-9864-1-git-send-email-maowenan@huawei.com> <20170117.141533.680344033700095483.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: maowenan <maowenan@huawei.com>, Netdev <netdev@vger.kernel.org>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:33302 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751156AbdAQT1h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 14:27:37 -0500
Received: by mail-it0-f68.google.com with SMTP id e137so224979itc.0
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 11:27:37 -0800 (PST)
In-Reply-To: <20170117.141533.680344033700095483.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 17, 2017 at 11:15 AM, David Miller <davem@davemloft.net> wrote:
> From: Mao Wenan <maowenan@huawei.com>
> Date: Mon, 9 Jan 2017 13:32:34 +0800
>
>> Relax ordering(RO) is one feature of 82599 NIC, to enable this feature can
>> enhance the performance for some cpu architecure, such as SPARC and so on.
>> Currently it only supports one special cpu architecture(SPARC) in 82599
>> driver to enable RO feature, this is not very common for other cpu architecture
>> which really needs RO feature.
>> This patch add one common config CONFIG_ARCH_WANT_RELAX_ORDER to set RO feature,
>> and should define CONFIG_ARCH_WANT_RELAX_ORDER in sparc Kconfig firstly.
>>
>> Signed-off-by: Mao Wenan <maowenan@huawei.com>
>
> Since no-one has reviewed this patch, and I do not feel comfortable with applying
> it without such review, I am tossing this patch.
>
> If someone eventually reviews it, repost this patch.

Mao,

Go ahead and repost the patch and feel free to add my Reviewed-by.
Sorry I didn't reply to this earlier but I have been getting over the
flu for the last week or so.

- Alex
