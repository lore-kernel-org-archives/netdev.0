From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: Two I/O memory regions in /proc/iomem for a NIC
Date: Sun, 2 Jul 2006 11:12:12 +0200
Message-ID: <20060702091212.GB30730@xi.wantstofly.org>
References: <ada605fb0607020024o15c8e4b4j83f37102492e8932@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:50907 "EHLO
	xi.wantstofly.org") by vger.kernel.org with ESMTP id S932426AbWGBJMO
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Jul 2006 05:12:14 -0400
To: John Que <qwejohn@gmail.com>
Content-Disposition: inline
In-Reply-To: <ada605fb0607020024o15c8e4b4j83f37102492e8932@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jul 02, 2006 at 10:24:10AM +0300, John Que wrote:

> I had noticed that there are machines where
> if I ran cat /proc/iomem I see one I/O memory region for the NIC
> I am using; while there are other machines where
> I see 2 regions for the NIC I/O memory.
> 
> For example, on a machine with e1000 NIC adapter,
> I see the following 2 I/O memory regions for the NIC:
> fc9a0000-fc9bffff : 0000:03:04.0
>    fc9a0000-fc9bffff : e1000
> fc9c0000-fc9dffff : 0000:03:03.0
>    fc9c0000-fc9dffff : e1000

Is it a dual-port NIC by any chance?


cheers,
Lennert
