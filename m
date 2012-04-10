From: Daniel Borkmann <danborkmann@iogearbox.net>
Subject: Re: axienet driver copyrights
Date: Tue, 10 Apr 2012 13:27:35 +0200
Message-ID: <CAD6jFURu+PTXqSUr7+sDba2oZq2QejAfJB7sRQHv2iOq4dLoDw@mail.gmail.com>
References: <4F84164C.6000702@monstr.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ariane Keller <ariane.keller@tik.ee.ethz.ch>,
	netdev@vger.kernel.org,
	John Williams <john.williams@petalogix.com>,
	John Linn <linnj@xilinx.com>,
	David Miller <davem@davemloft.net>
To: monstr@monstr.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:51296 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750946Ab2DJL1o convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 07:27:44 -0400
Received: from [78.46.4.229] (helo=sslproxy03.your-server.de)
	by www62.your-server.de with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.74)
	(envelope-from <danborkmann@iogearbox.net>)
	id 1SHZEc-0005T6-Eh
	for netdev@vger.kernel.org; Tue, 10 Apr 2012 13:27:42 +0200
Received: from [209.85.215.174] (helo=mail-ey0-f174.google.com)
	by sslproxy03.your-server.de with esmtpsa (TLS1.0:RSA_ARCFOUR_SHA1:16)
	(Exim 4.72)
	(envelope-from <danborkmann@iogearbox.net>)
	id 1SHZ86-0005jJ-AU
	for netdev@vger.kernel.org; Tue, 10 Apr 2012 13:20:58 +0200
Received: by eaaq12 with SMTP id q12so1268581eaa.19
        for <netdev@vger.kernel.org>; Tue, 10 Apr 2012 04:27:36 -0700 (PDT)
In-Reply-To: <4F84164C.6000702@monstr.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 10, 2012 at 1:15 PM, Michal Simek <monstr@monstr.eu> wrote:
> Dear Ariane and Daniel, [cc: John Linn, John Williams, David Miller a=
nd
> netdev]
>
> I have several questions about one patch which was added to mainline =
Linux
> tree.
> Below is information about the patch:
>
> drivers/net/ethernet/xilinx: added Xilinx AXI Ethernet driver
> (sha1: 8a3b7a252dca9fb28c23b5bf76c49180a2b60d3b)
>
> The whole driver contains your copyright in 3 files but I don't belie=
ve
> that you are authors of significant changes to be polite to write the=
re your
> copyright.
> I really appreciate that someone invested time to add this driver to =
the
> mainline
> but I am not comfortable that you will be identify as authors of this=
 driver
> because you are not!
>
> Maintainer for this driver should be Xilinx which has done this drive=
r. I
> also
> see that you have integrated all changes I have done to it. We have d=
one
> these
> changes on Xilinx request to improve the driver stability and perform=
ance.
>
> I have spent some time to list your changes you have done to be sure =
that my
> first feeling was wrong but it is not.
>
> There are changes which do nothing with functionality.
> 1. Clean the driver by checkpatch.pl script.
> 2. Copy axienet_ior/iow to header file
> 3. axienet_device_reset resort.
>
> Can you tell me what significant changes you have done in this driver=
?
>
> I know the whole history of this driver and I have never heard about =
you
> and your changes pointing me that you have just took the latest versi=
on
> from PetaLogix or Xilinx git repository and use checkpatch.pl script
> to fix coding style violations.
>
> I don't think that using checkpatch + 2 simple changes is not enough
> to be identified as author.
>
> Can you please correct me?

Yes, we mainly spent time to refactor this patch (in particular
removing duplicate code parts), make it work under the latest kernel,
make it kernel coding convention compliant and included it into
Kconfig.

But feel free to remove us from the header, sure, that should be no
problem at all.

I guess we should have CC'ed you when submitting. Sorry that we have
forgotten that.

> Thanks,
> Michal
>
> David: Would it be possible to ping me everytime when there is any pa=
tch
> around xilinx ethernet controller. I have all equipment for testing i=
t
> and it is my day job to take care about microblaze/xilinx drivers.
>
>
>
>
> --
> Michal Simek, Ing. (M.Eng)
> w: www.monstr.eu p: +42-0-721842854
> Maintainer of Linux kernel 2.6 Microblaze Linux - http://www.monstr.e=
u/fdt/
> Microblaze U-BOOT custodian
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
