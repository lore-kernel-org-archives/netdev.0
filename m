From: Marc Bertola <marc.bertola@prolucid.ca>
Subject: Re: Correct method for initializing Pause and Asymmetrical Pause
 support in phy drivers
Date: Thu, 12 Jan 2017 11:52:46 -0500
Message-ID: <CAMqDo0Wy0MkOvtqj84U=Dm6rb+BBSVNREAndBLGvojMHYirgaw@mail.gmail.com>
References: <CAMqDo0XxvtjD+uJQeHJuSyN71zEEa5AB9YE1CUYK8wq2NGeAbQ@mail.gmail.com>
 <68c58b10-1458-636e-a4a6-686a17ba743b@neratec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Florian Fainelli <f.fainelli@gmail.com>,
        Timur Tabi <timur@codeaurora.org>
To: Zefir Kurtisi <zefir.kurtisi@neratec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:35195 "EHLO
        mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750773AbdALQxH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 11:53:07 -0500
Received: by mail-oi0-f51.google.com with SMTP id j15so29602951oih.2
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 08:53:07 -0800 (PST)
In-Reply-To: <68c58b10-1458-636e-a4a6-686a17ba743b@neratec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yes! This solution makes most sense, as Pause support is definitely on
the MAC side.

I thought this was not allowed because I was following instructions
from a stale copy of phy.txt -- I figured my copy was good because the
"last update" date at the top of the master file was the same. (It is
still 2008-04-08  -- see
https://github.com/torvalds/linux/blob/master/Documentation/networking/phy.txt)

Thank you very much for your swift response. This whole issue has been
very interesting to investigate. I'll take a look at Timur's cleanup
and respect that approach as I repair the older copy of kernel that I
am working with for this project.
