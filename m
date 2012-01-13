From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH] Making de2104x working with BNC connection on 21040 chipset
Date: Fri, 13 Jan 2012 13:43:58 -0500
Message-ID: <CAP=VYLpWbcBae11fcQPcuPmdfvir7N6F9QMdzXip=i4mMHjxsQ@mail.gmail.com>
References: <4F0F641B.5090407@t-online.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Michael Mueller <malware@t-online.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:45133 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752364Ab2AMSn6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2012 13:43:58 -0500
Received: by ggdk6 with SMTP id k6so1801510ggd.19
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2012 10:43:58 -0800 (PST)
In-Reply-To: <4F0F641B.5090407@t-online.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 12, 2012 at 5:52 PM, Michael Mueller <malware@t-online.de> wrote:
> Hi,
>
> while I recently updated an older machine to the latest Debian
> distribution which included updating the kernel from 2.4.x to 3.0 the
> tulip driver did stop working for my network card. The replacement
> driver de2104x did initialize the network interfaces but no transmission
> was possible.

Did you try the original de4x5.c driver?   I believe it was all that existed
back in the 2.4 vintage, and I think it was kept around just to keep old
cards that didn't like the "new" tulip driver working.

Paul.

>
> Digging into it I found the de2104x driver just assumes there is no BNC
> transceiver on a card using the 21040 chipset. So I extracted the
> correct configuration values from the old tulip driver and removed some
> sanity checking which denied setting the transceiver to BNC. Now I can
> use the driver by just setting the correct transceiver using ethtool.
>
> A patch against 3.0 is appended. It should apply against more recent
> versions too since there was not the lot happening for this old driver,
> but for the relocation of the files from drivers/net/tulip to
> drivers/net/ethernet/dec/tulip.
>
>
> Michael
>
