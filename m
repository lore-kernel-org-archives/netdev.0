From: =?UTF-8?Q?Sjur_Br=C3=A6ndeland?= <sjurbren@gmail.com>
Subject: Re: CAIF transmit bug
Date: Sun, 22 May 2011 23:35:03 +0200
Message-ID: <BANLkTi=DnD9eMiP_+H491T0ejXjYWAmBow@mail.gmail.com>
References: <20110519.174415.182212433770446975.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:42651 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755042Ab1EVVfF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2011 17:35:05 -0400
Received: by bwz15 with SMTP id 15so4240269bwz.19
        for <netdev@vger.kernel.org>; Sun, 22 May 2011 14:35:03 -0700 (PDT)
In-Reply-To: <20110519.174415.182212433770446975.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

> net/caif/cfctrl.c:cfctrl_enum_req() does not check the return value of
> the ->transmit() method.
>
> The documentation for this method states that one error, ownership
> of the packet is transferred back to the caller, which means that we
> have a leak here.
>
> Please fix this bug.

The documentation was unfortunately outdated.
I just sent a patch-set including a fix for this.

Thank you for reviewing this.

Regards,
Sjur
