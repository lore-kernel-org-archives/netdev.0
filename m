From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH resend] ethtool: add register dump support for fjes driver
Date: Wed, 23 Nov 2016 09:56:47 -0500
Message-ID: <20161123145646.GA13179@tuxdriver.com>
References: <1479257733-19277-1-git-send-email-izumi.taku@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Taku Izumi <izumi.taku@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:43357 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938652AbcKWPAQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 10:00:16 -0500
Content-Disposition: inline
In-Reply-To: <1479257733-19277-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 16, 2016 at 09:55:32AM +0900, Taku Izumi wrote:
> This patch adds the register dump format for FUJITSU Extended
> Network device like the following:
> 
>    # ethtool -d es0
> 
> 0x0000: OWNER_EPID    (Owner EPID)                       0x00000001
> 0x0004: MAX_EP        (Maximum EP)                       0x00000008
> 0x0010: DCTL          (Device Control)                   0x00000000
> 0x0020: CR            (Command request)                  0x80000002
> 0x0024: CS            (Command status)                   0x80000002
> 0x0028: SHSTSAL       (Share status address Low)         0xE8215304
> 0x002C: SHSTSAH       (Share status address High)        0x00000007
> 0x0034: REQBL         (Request Buffer length)            0x00008028
> 0x0038: REQBAL        (Request Buffer Address Low)       0xEB0A0000
> 0x003C: REQBAH        (Request Buffer Address High)      0x00000007
> 0x0044: RESPBL        (Response Buffer Length)           0x00000018
> 0x0048: RESPBAL       (Response Buffer Address Low)      0xE41E1220
> 0x004C: RESPBAH       (Response Buffer Address High)     0x00000007
> 0x0080: IS            (Interrupt status)                 0x00000000
> 0x0084: IMS           (Interrupt mask set)               0x7FE00000
> 0x0088: IMC           (Interrupt mask clear)             0x001F0000
> 0x008C: IG            (Interrupt generator)              0x00010000
> 0x0090: ICTL          (Interrupt control)                0x00000000
> 
> Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>

Thank you, Taku Izumi. I have merged this patch and will be pushing
it shortly.

I apologize for the delay.

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
