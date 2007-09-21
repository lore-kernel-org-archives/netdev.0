From: Denys Vlasenko <vda.linux@googlemail.com>
Subject: Re: [PATCH 1/2] bnx2: factor out gzip unpacker
Date: Fri, 21 Sep 2007 20:18:06 +0100
Message-ID: <200709212018.06553.vda.linux@googlemail.com>
References: <200709211201.24475.vda.linux@googlemail.com> <200709211905.23946.vda.linux@googlemail.com> <15775.1190399812@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jeff@garzik.org,
	mchan@broadcom.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Valdis.Kletnieks@vt.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:54865 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752243AbXIUTSN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2007 15:18:13 -0400
Received: by ug-out-1314.google.com with SMTP id z38so575223ugc
        for <netdev@vger.kernel.org>; Fri, 21 Sep 2007 12:18:12 -0700 (PDT)
In-Reply-To: <15775.1190399812@turing-police.cc.vt.edu>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 21 September 2007 19:36, Valdis.Kletnieks@vt.edu wrote:
> On Fri, 21 Sep 2007 19:05:23 BST, Denys Vlasenko said:
> 
> > I plan to use gzip compression on following drivers' firmware,
> > if patches will be accepted:
> > 
> >    text    data     bss     dec     hex filename
> >   17653  109968     240  127861   1f375 drivers/net/acenic.o
> >    6628  120448       4  127080   1f068 drivers/net/dgrs.o
> >          ^^^^^^
> 
> Should this be redone to use the existing firmware loading framework to
> load the firmware instead?

Not in every case.

For example, bnx2 maintainer says that driver and
firmware are closely tied for his driver. IOW: you upgrade kernel
and your NIC is not working anymore.

Another argument is to make kernel be able to bring up NICs
without needing firmware images in initramfs/initrd/hard drive.
--
vda
