From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] net: ioctl SIOCSIFADDR minor cleanup
Date: Mon, 21 Nov 2016 20:20:22 -0800
Message-ID: <CAM_iQpW0SnpXfN-DjBm-72_23KxtzH8kXbbc3FiQn=VChdX3Ww@mail.gmail.com>
References: <1479213899-5952-1-git-send-email-cugyly@163.com>
 <20161115.220108.1225196299725031215.davem@davemloft.net> <8729016553E3654398EA69218DA29EEF0E42F73A@cnshjmbx02>
 <20161115.223111.734917440131578613.davem@davemloft.net> <8729016553E3654398EA69218DA29EEF0E42F7ED@cnshjmbx02>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        "cugyly@163.com" <cugyly@163.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: YUAN Linyu <Linyu.Yuan@alcatel-sbell.com.cn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:36404 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755050AbcKVEUn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2016 23:20:43 -0500
Received: by mail-io0-f195.google.com with SMTP id k19so9508629iod.3
        for <netdev@vger.kernel.org>; Mon, 21 Nov 2016 20:20:43 -0800 (PST)
In-Reply-To: <8729016553E3654398EA69218DA29EEF0E42F7ED@cnshjmbx02>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 15, 2016 at 7:57 PM, YUAN Linyu
<Linyu.Yuan@alcatel-sbell.com.cn> wrote:
> No, this patch will not change dev->name,
> It's care about ifa->ifa_label.
>> -                     if (colon)
>> -                             memcpy(ifa->ifa_label, ifr.ifr_name, IFNAMSIZ);
>> -                     else
>> -                             memcpy(ifa->ifa_label, dev->name, IFNAMSIZ);
> When ifr.ifr_name have no colon, dev->name must equal to ifr.ifr_name.
> So we change to
>> -                     else
>> -                             memcpy(ifa->ifa_label, ifr.ifr_name, IFNAMSIZ);
> Then if and else do same thing. Just one line is enough,
> memcpy(ifa->ifa_label, ifr.ifr_name, IFNAMSIZ);
>

I don't understand why you try to optimize a slow path and some kind of
obsolete code.
