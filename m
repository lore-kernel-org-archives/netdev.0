From: Denys Vlasenko <vda.linux@googlemail.com>
Subject: Re: [PATCH 1/2] bnx2: factor out gzip unpacker
Date: Fri, 21 Sep 2007 23:37:52 +0100
Message-ID: <200709212337.53043.vda.linux@googlemail.com>
References: <200709211201.24475.vda.linux@googlemail.com> <200709211905.23946.vda.linux@googlemail.com> <p73ps0b93ph.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jeff@garzik.org,
	mchan@broadcom.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:29629 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932134AbXIUWi1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2007 18:38:27 -0400
Received: by ug-out-1314.google.com with SMTP id z38so597098ugc
        for <netdev@vger.kernel.org>; Fri, 21 Sep 2007 15:38:25 -0700 (PDT)
In-Reply-To: <p73ps0b93ph.fsf@bingen.suse.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 21 September 2007 21:13, Andi Kleen wrote:
> Denys Vlasenko <vda.linux@googlemail.com> writes:
> > 
> > I plan to use gzip compression on following drivers' firmware,
> > if patches will be accepted:
> > 
> >    text    data     bss     dec     hex filename
> >   17653  109968     240  127861   1f375 drivers/net/acenic.o
> >    6628  120448       4  127080   1f068 drivers/net/dgrs.o
> >          ^^^^^^
> 
> Just change the makefiles to always install gzip'ed modules
> modutils knows how to unzip them on the fly.

But I compile net/* into bzImage. I like netbooting :)
--
vda
