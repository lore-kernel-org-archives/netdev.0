From: Nikita Yushchenko <nikita.yoush@cogentembedded.com>
Subject: Re: Kernel crashes in phy_attach_direct()
Date: Wed, 8 Feb 2017 17:41:37 +0300
Message-ID: <0cabd359-a048-87a5-c78c-3b803525e4fa@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Fabio Estevam <festevam@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f53.google.com ([209.85.215.53]:33763 "EHLO
        mail-lf0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753874AbdBHOlu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 09:41:50 -0500
Received: by mail-lf0-f53.google.com with SMTP id x1so83244013lff.0
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 06:41:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Hi,
>
> I am getting the following kernel crash with linux-next 20170208
> running on a imx53-qsb board.
>
> Any ideas?

Same here, on zii-dev-revB and zii-dev-revC boards.

Crash is in phy_attach_direct() in line

    if (!try_module_get(d->driver->owner)) {

caused by d->driver being NULL.

Nikita
