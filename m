From: William Tu <u9012063@gmail.com>
Subject: Re: [PATCH net-next] ip_gre: check packet length and mtu correctly in erspan_fb_xmit
Date: Fri, 6 Oct 2017 15:51:05 -0700
Message-ID: <CALDO+SZCXUq_CSq_GRRQyBeVFWh1F-jBZDMyPsvcB-ghHbZSpQ@mail.gmail.com>
References: <CALDO+SZPmF_UG9BsZKD2FzJUbx0PcUYKrOpp4Xta4Wufezhh+g@mail.gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DD008B9C8@AcuExch.aculab.com>
 <CALDO+SYDGtipnsXOmcFmCRB2QcgjjzoWVB=T71=r7U834ivPjg@mail.gmail.com> <20171006.232229.74190380417429379.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Laight <David.Laight@aculab.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Xin Long <lucien.xin@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f42.google.com ([209.85.214.42]:43928 "EHLO
        mail-it0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751485AbdJFWvq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 18:51:46 -0400
Received: by mail-it0-f42.google.com with SMTP id k70so492661itk.0
        for <netdev@vger.kernel.org>; Fri, 06 Oct 2017 15:51:46 -0700 (PDT)
In-Reply-To: <20171006.232229.74190380417429379.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 6, 2017 at 3:22 PM, David Miller <davem@davemloft.net> wrote:
> From: William Tu <u9012063@gmail.com>
> Date: Fri, 6 Oct 2017 15:09:29 -0700
>
>> Yes, adding another field in the struct net_device can avoid the
>> arithmetic operation. I'm not sure it's a good idea to add new field
>> since there are already a lot in net_device.  Let's wait to see how
>> others think.
>
> Why would you add it to net_device when you can add it to ip_tunnel?
>
I see. I will add it to ip_tunnel and resubmit the patch. Thanks!
