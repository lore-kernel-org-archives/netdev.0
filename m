From: Philippe Reynes <tremyfr@gmail.com>
Subject: Re: [PATCH] net: aquantia: atlantic: use new api ethtool_{get|set}_link_ksettings
Date: Mon, 30 Jan 2017 22:26:44 +0100
Message-ID: <CAC=8w93PE4jv-j+66qOxtXvfb5jRNskWhunDwd3BfQsLsci78w@mail.gmail.com>
References: <1485610661-21099-1-git-send-email-tremyfr@gmail.com> <1485792782-5634-1-git-send-email-pavel.s.belous@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Pavel Belous <pavel.s.belous@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:36507 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754386AbdA3VfP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 16:35:15 -0500
Received: by mail-wm0-f45.google.com with SMTP id c85so233909008wmi.1
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 13:35:15 -0800 (PST)
In-Reply-To: <1485792782-5634-1-git-send-email-pavel.s.belous@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Pavel,

On 1/30/17, Pavel Belous <pavel.s.belous@gmail.com> wrote:
> Hi Philippe,
>
> thanks you for your patch, it looks good.
> One improvement - could you please add support/advertising for TP?
>
>>+	supported |= SUPPORTED_Autoneg;
> need:
> 	supported |= SUPPORTED_TP;
>
>
>>+	advertising = (self->aq_nic_cfg.is_autoneg) ?
>> 							ADVERTISED_Autoneg : 0U;
>
> need:
> 	advertising |= ADVERTISED_TP;
>

Yes, of course, I add send, and I send a v2.

> Thank you.

Regards,
Philippe
