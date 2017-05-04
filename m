From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: new warning at net/wireless/util.c:1236
Date: Thu, 04 May 2017 08:41:57 +0200
Message-ID: <1493880117.3521.1.camel@sipsolutions.net>
References: <CA+55aFxyp5gpUZEYHXLwyhbK6DMWf4RoVykGxq9FPtO=j4yJsw@mail.gmail.com>
         (sfid-20170504_042831_013058_9FF7CF3D)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Wireless List <linux-wireless@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:50274 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751530AbdEDGmE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 4 May 2017 02:42:04 -0400
In-Reply-To: <CA+55aFxyp5gpUZEYHXLwyhbK6DMWf4RoVykGxq9FPtO=j4yJsw@mail.gmail.com> (sfid-20170504_042831_013058_9FF7CF3D)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> Things still work, but when it starts warning, it generates a *lot*
> of noise (I got 36 of these within about ten minutes).

Yeah, that's kinda dumb - I just sent a patch to make that just warn
once and actually report the configuration.

> I have no idea what triggered it, because when I rebooted (not
> because of this issue, but just to reboot into a newer kernel) I
> don't see it again.

That's odd. Perhaps you connected to a different wireless network on
the next boot? I'm pretty sure I found the cause for this, and will
send out a patch in a minute, but that wouldn't go away with a
different kernel.

johannes
