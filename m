From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: net: Fix inconsistent teardown and release of private netdev state.
Date: Thu, 6 Jul 2017 16:28:25 +0200
Message-ID: <CAHmME9qKjLSCU2LdZ1_7CCxvNfmuY1=iC0+LgRa+32hFLT71zw@mail.gmail.com>
References: <20170706142427.GA32086@zx2c4.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:52949 "EHLO frisell.zx2c4.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751975AbdGFO2i (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 6 Jul 2017 10:28:38 -0400
Received: by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTP id 794106f0
        for <netdev@vger.kernel.org>;
        Thu, 6 Jul 2017 14:24:21 +0000 (UTC)
Received: by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTPSA id ff4ec4cb (TLSv1.2:ECDHE-RSA-AES128-GCM-SHA256:128:NO)
        for <netdev@vger.kernel.org>;
        Thu, 6 Jul 2017 14:24:21 +0000 (UTC)
Received: by mail-wr0-f176.google.com with SMTP id 77so5351816wrb.1
        for <netdev@vger.kernel.org>; Thu, 06 Jul 2017 07:28:26 -0700 (PDT)
In-Reply-To: <20170706142427.GA32086@zx2c4.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 6, 2017 at 4:24 PM, Jason A. Donenfeld <Jason@zx2c4.com> wrote:
>
>         if (!ret)
>                 pr_info("Yay it worked!\n");
>
>         return 0;

This is supposed to be `return ret;`. See, even in psuedocode it's
hard to get right.
