From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Atheros Communications Inc. AR8121/AR8113/AR8114 Gigabit or Fast Ethernet (rev b0) 1.0.0.7 md5/sha1 corrupted using NFS and samba (updated) Version 2
Date: Sat, 23 Mar 2013 16:06:55 +0100
Message-ID: <20130323150655.GA10779@order.stressinduktion.org>
References: <514CE440.3010003@gmail.com> <1363996448.4431.73.camel@edumazet-glaptop> <514CF23A.3010702@gmail.com> <20130323021008.GC939@order.stressinduktion.org> <514D3581.4040001@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: rebelyouth <rebelyouth.hacklab@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:53705 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750973Ab3CWPG5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Mar 2013 11:06:57 -0400
Content-Disposition: inline
In-Reply-To: <514D3581.4040001@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 23, 2013 at 12:54:25AM -0400, rebelyouth wrote:
> I applied your patch on my the kernel 3.7.9 and look like the patch do 
> what you said before :
> 
> "This does not solve the real problem, which I have not yet understood 
> (wrong packets will be discarded now and will be hopefully resend). "
> 
> There are errors on the RX side of the server and the speed is 5~10% 
> less but the files are ok in nfsv4 , SFTP/FTP and samba.
> 
> Maybe the Atheros drivers for windows had a patch for the checksum 
> already in the drivers and the chipset  have some hardware bug, but for 
> me your patch is already an achievement and I really thank you for your 
> time and consideration.

The upstream driver (which is a tarball I found with google
AR81Family-linux-v1.0.1.14.tar.gz) has this function ifdefed out. I have
a couple of more things I want to test as soon as I have access to the
hardware again.  If I don't find a better solution I will submit a patch
which disables rx checksumming as a whole for inclusion to net-next.

Thanks,

  Hannes
