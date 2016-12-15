From: Yendapally Reddy Dhananjaya Reddy <yendapally.reddy@broadcom.com>
Subject: Re: [PATCH 0/6] USB support for Broadcom NSP SoC
Date: Thu, 15 Dec 2016 09:00:08 +0530
Message-ID: <CAL2FKY=Xir2s-2_F1H9wosf8eGr+hP1ZKrVLqqPs4FfQNLx+kw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Russell King <linux@armlinux.org.uk>,
        Ray Jui <rjui@broadcom.com>,
        Scott Branden <sbranden@broadcom.com>,
        Jon Mason <jonmason@broadcom.com>,
        Kishon Vijay Abraham I <kishon@ti.com>,
        BCM Kernel Feedback <bcm-kernel-feedback-list@broadcom.com>,
        netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f172.google.com ([209.85.220.172]:36442 "EHLO
        mail-qk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753214AbcLODaZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2016 22:30:25 -0500
Received: by mail-qk0-f172.google.com with SMTP id n21so43402340qka.3
        for <netdev@vger.kernel.org>; Wed, 14 Dec 2016 19:30:09 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 13, 2016 at 7:50 AM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> On 11/09/2016 01:33 AM, Yendapally Reddy Dhananjaya Reddy wrote:
>> This patch set contains the usb support for Broadcom NSP SoC.
>> The usb phy is connected through mdio interface. The mdio interface
>> can be used to access either internal phys or external phys using a
>> multiplexer.
>>
>> The first patch provides the documentation details for mdio-mux and
>> second patch provides the documentation details for usb3 phy. The third
>> patch contains the mdio-mux support and fourth patch contains the
>> changes to the mdio bus driver.
>>
>> The fifth patch provides the phy driver and sixth patch provides the
>> enable method for usb.
>>
>> This patch series has been tested on NSP bcm958625HR board.
>> This patch series is based on v4.9.0-rc1 and is available from github-
>> repo: https://github.com/Broadcom/cygnus-linux.git
>> branch:nsp-usb-v1
>
> Can you resubmit this patch series with the feedback from Andrew, Rob
> and Scott addressed?
>
> Thanks!

Hi Florian,

I addressed all the comments. The change suggested by Andrew requires the
latest patches of "mdio-mux-mmioreg" available in "net-next". I need to wait
 until these changes are in mainline.

Thanks
Dhananjay

> --
> Florian
