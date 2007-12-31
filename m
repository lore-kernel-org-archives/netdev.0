From: Adrian Bunk <bunk@kernel.org>
Subject: Re: [PATCH] Force UNIX domain sockets to be built in
Date: Mon, 31 Dec 2007 14:24:19 +0200
Message-ID: <20071231122419.GA13803@does.not.exist>
References: <alpine.LSU.0.999.0712311300020.3686@be1.lrz>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Jan Engelhardt <jengelh@computergmbh.de>, devzero@web.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Bodo Eggert <7eggert@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6.pp.htv.fi ([213.243.153.40]:54367 "EHLO smtp6.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757382AbXLaMYb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Dec 2007 07:24:31 -0500
Content-Disposition: inline
In-Reply-To: <alpine.LSU.0.999.0712311300020.3686@be1.lrz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 31, 2007 at 01:09:43PM +0100, Bodo Eggert wrote:
> As suggested by Adrian Bunk, UNIX domain sockets should always be built in 
> on normal systems. This is especially true since udev needs these sockets
> and fails to run if UNIX=m.
> 
> Signed-Off-By: Bodo Eggert <7eggert@gmx.de>
> 
> ---
> Last minute change: I decided against making it a bool because embedded 
> folks might depend on a small kernel image. Edited in the patch below.
>...

Is this just a purely theoretical thought or is this a reasonable use 
case people actually use in practice?

After all, changing it to a bool will allow us to make the kernel image 
for nearly everyone smaller by a few hundred bytes...

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

