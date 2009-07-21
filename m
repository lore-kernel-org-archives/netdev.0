From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Kernel oops on setting sky2 interfaces down
Date: Tue, 21 Jul 2009 13:54:52 -0700
Message-ID: <20090721135452.421d0331@nehalam>
References: <4A65EC3F.4050400@gibraltar.at>
	<20090721095853.30f4fbda@nehalam>
	<4A661E36.7000109@gibraltar.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Richard Leitner <leitner@esys.at>
To: Rene Mayrhofer <rene.mayrhofer@gibraltar.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54702 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754943AbZGUUy6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jul 2009 16:54:58 -0400
In-Reply-To: <4A661E36.7000109@gibraltar.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 21 Jul 2009 21:59:50 +0200
Rene Mayrhofer <rene.mayrhofer@gibraltar.at> wrote:

> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
> Stephen Hemminger wrote:
> > Looks like the device is disappearing from the PCI bus when
> > brought down.  Can you reproduce it with 2.6.30.2 or 2.6.31-rc3?
> > 
> > Try later kernels.  
> This is, as mentioned in my initial email, unfortunately not an option
> until later kernel support squashfs-lzma again. These embedded
> appliances boot from compact flash with the root FS in squashfs.
> 
> The question probably is if newer sky2 module sources would compile and
> work with 2.6.28.10. Is this expected to work?

Kernel api (net_device_ops) changes are not in 2.6.28 as remember.
