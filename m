From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [IOC3] Fix section missmatch
Date: Mon, 17 Mar 2008 08:13:27 -0400
Message-ID: <47DE6067.6070500@garzik.org>
References: <20080308165833.GA8625@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	linux-mips@linux-mips.org
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52392 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752395AbYCQMNb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Mar 2008 08:13:31 -0400
In-Reply-To: <20080308165833.GA8625@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ralf Baechle wrote:
>   LD      drivers/net/built-in.o
> WARNING: drivers/net/built-in.o(.text+0x3468): Section mismatch in reference fro
> m the function ioc3_probe() to the function .devinit.text:ioc3_serial_probe()
> The function ioc3_probe() references
> the function __devinit ioc3_serial_probe().
> This is often because ioc3_probe lacks a __devinit 
> annotation or the annotation of ioc3_serial_probe is wrong.
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
> 
> ---
> Resend, this time with Jeff's address corrected.

applied


