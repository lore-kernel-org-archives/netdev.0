From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2 0/3] net: ethernet: Allow Marvell & Freescale
 to COMPILE_TEST
Date: Tue, 15 Nov 2016 16:37:04 -0800
Message-ID: <a720eade-03e3-ae71-1946-0200d92734d6@gmail.com>
References: <20161116003541.18415-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, mw@semihalf.com, arnd@arndb.de,
        gregory.clement@free-electrons.com, Shaohui.Xie@freescale.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33446 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934056AbcKPAhH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 19:37:07 -0500
Received: by mail-pf0-f193.google.com with SMTP id 144so8724574pfv.0
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2016 16:37:06 -0800 (PST)
In-Reply-To: <20161116003541.18415-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/15/2016 04:35 PM, Florian Fainelli wrote:
> Hi David,
> 
> This patch series allows most of the Freescale Ethernet drivers to be built
> with COMPILE_TEST and all Marvell drivers to build with COMPILE_TEST.
> 
> This is helpful to increase build coverage without requiring hacking into
> Kconfig anymore.
> 
> Changes in v2:
> 
> - rename register define clash when building for i386 (spotted by LKP)
> 
> Florian Fainelli (3):
>   net: fsl: Allow most drivers to be built with COMPILE_TEST
>   net: gianfar_ptp: Rename FS bit to FIPERST

This should be the first patch, I will resubmit.
-- 
Florian
