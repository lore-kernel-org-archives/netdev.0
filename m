From: Fabio Estevam <festevam@gmail.com>
Subject: Re: Poor IPv6 TCP performance in 4.3-rc3
Date: Tue, 29 Sep 2015 20:40:22 -0300
Message-ID: <CAOMZO5Be8BwYP7fhzKkNWOKNgtPZ9PwtFJtknku0rPaOZ16ghg@mail.gmail.com>
References: <20150929233253.GS21513@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:36602 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751309AbbI2XkY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 19:40:24 -0400
Received: by igcrk20 with SMTP id rk20so89750509igc.1
        for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 16:40:23 -0700 (PDT)
In-Reply-To: <20150929233253.GS21513@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Russell,

On Tue, Sep 29, 2015 at 8:32 PM, Russell King - ARM Linux
<linux@arm.linux.org.uk> wrote:
> Hi,
>
> I'm seeing really poor IPv6 performance compared to IPv4.  I've
> checked using two different ARM platforms - an iMX6 platform using
> the FEC driver, and an Armada 38x using mvneta.

Does this patch help?
https://patchwork.ozlabs.org/patch/523632/

It was suggested in the following thread:
https://lkml.org/lkml/2015/9/29/258

and it seems to have fixed the performance issue.

Regards,

Fabio Estevam
