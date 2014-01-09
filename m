From: Amir Vadai <amirv@mellanox.com>
Subject: Re: mlx4 w/ IOMMU broken, kernel 3.12.6 -- resolved
Date: Thu, 9 Jan 2014 15:24:08 +0200
Message-ID: <20140109132406.GB27750@mtl-eit-vdi-22.mtl.labs.mlnx>
References: <20140108134917.GC351037@jupiter.n2.diac24.net>
 <20140109075411.GA27750@mtl-eit-vdi-22.mtl.labs.mlnx>
 <20140109124619.GD351037@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f41.google.com ([74.125.83.41]:57456 "EHLO
	mail-ee0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754592AbaAINYM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 08:24:12 -0500
Received: by mail-ee0-f41.google.com with SMTP id e53so258188eek.0
        for <netdev@vger.kernel.org>; Thu, 09 Jan 2014 05:24:11 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20140109124619.GD351037@jupiter.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/01/14 13:46 +0100, David Lamparter wrote:
> On Thu, Jan 09, 2014 at 09:54:15AM +0200, Amir Vadai wrote:
> > What is the firmware version?
> > You can get it by issuing 'ethtool -i <interface>'
> > 
> > Please make sure you're using the latest FW from mellanox.com.
> 
> Ah, indeed updating from 2.11.500 to 2.30.8000 has fixed the issue.
Good to hear :)

> (The driver could print a warning for this?)
It is just an old firmware, users are suggested to use the latest one.

> 
> (Note: updating the firmware has been rather annoying due to the complex
> and complicated way the OEM branding [this is an IBM card] is designed.
> If you have some way of passing up user experience feedback, please put
> a note down on this.)
> 
> > We still don't have MLNX_OFED package that supports this kernel.
> 
> I noticed, the kernel driver from the external package is referencing
> things that have disappeared from the kernel around version 3.8.  Though
> I don't see why there is both an in-kernel driver and a separate
> package...
I will pass it.

> 
> Thanks for the firmware pointer,
> 
> 
> David
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Amir.
