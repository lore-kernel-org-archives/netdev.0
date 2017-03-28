From: Jonas Jensen <jonas.jensen@gmail.com>
Subject: Re: [PATCH v2] net: moxa: fix TX overrun memory leak
Date: Tue, 28 Mar 2017 12:18:04 +0200
Message-ID: <CACmBeS1E4TrUzq5-L_y0=dFY6=HdGAJSbsaBW2mfmvxctWvX2A@mail.gmail.com>
References: <1490617879-14014-1-git-send-email-jonas.jensen@gmail.com> <20170327.205026.1935467634311224337.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:34278 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754976AbdC1KSM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 06:18:12 -0400
In-Reply-To: <20170327.205026.1935467634311224337.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28 March 2017 at 05:50, David Miller <davem@davemloft.net> wrote:
> Doing the wakeup unconditionally is very wasteful, you just need to do it
> when enough space has been made available.

Thanks, please see v3.


   Jonas
