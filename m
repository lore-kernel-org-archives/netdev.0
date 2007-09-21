From: Denys Vlasenko <vda.linux@googlemail.com>
Subject: Re: [PATCH 1/2] bnx2: factor out gzip unpacker
Date: Fri, 21 Sep 2007 23:43:40 +0100
Message-ID: <200709212343.41160.vda.linux@googlemail.com>
References: <200709211201.24475.vda.linux@googlemail.com> <200709212018.06553.vda.linux@googlemail.com> <Pine.LNX.4.64.0709212130490.11228@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Valdis.Kletnieks@vt.edu, David Miller <davem@davemloft.net>,
	jeff@garzik.org, mchan@broadcom.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Krzysztof Oledzki <olel@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:34873 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932812AbXIUWnt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2007 18:43:49 -0400
Received: by ug-out-1314.google.com with SMTP id z38so597429ugc
        for <netdev@vger.kernel.org>; Fri, 21 Sep 2007 15:43:48 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.64.0709212130490.11228@bizon.gios.gov.pl>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 21 September 2007 20:33, Krzysztof Oledzki wrote:
> 
> On Fri, 21 Sep 2007, Denys Vlasenko wrote:
> 
> > On Friday 21 September 2007 19:36, Valdis.Kletnieks@vt.edu wrote:
> >> On Fri, 21 Sep 2007 19:05:23 BST, Denys Vlasenko said:
> >>
> >>> I plan to use gzip compression on following drivers' firmware,
> >>> if patches will be accepted:
> >>>
> >>>    text    data     bss     dec     hex filename
> >>>   17653  109968     240  127861   1f375 drivers/net/acenic.o
> >>>    6628  120448       4  127080   1f068 drivers/net/dgrs.o
> >>>          ^^^^^^
> >>
> >> Should this be redone to use the existing firmware loading framework to
> >> load the firmware instead?
> >
> > Not in every case.
> >
> > For example, bnx2 maintainer says that driver and
> > firmware are closely tied for his driver. IOW: you upgrade kernel
> > and your NIC is not working anymore.
>
> Firmware may come with a kernel. We have a "install modules", we can also 
> add "install firmware".

Install where? I boot my machine over NFS, and it has no hard drive.

> > Another argument is to make kernel be able to bring up NICs
> > without needing firmware images in initramfs/initrd/hard drive.
> 
> It is not possible to bring up things like FC or WiFi without firmware, 
> what special is in classic NICs?

Nothing.

It is just not (yet?) decreed from The Very Top that all and every
firmware image should be loaded using request_firmware().

Also people may want to gzip something else than firmware.
--
vda
