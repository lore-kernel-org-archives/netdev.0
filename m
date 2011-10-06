From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: A new 40G Network driver ready to submit to the kernel tree
Date: Thu, 6 Oct 2011 13:00:56 +0200
Message-ID: <20111006110056.GB27447@electric-eye.fr.zoreil.com>
References: <4E8CE4A0.4060202@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Joyce Yu - System Software <joyce.yu@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:33108 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935418Ab1JFLDA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2011 07:03:00 -0400
Content-Disposition: inline
In-Reply-To: <4E8CE4A0.4060202@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joyce Yu - System Software <joyce.yu@oracle.com> :
[...]
> I have a new 40G Network driver ready to submit to the kernel tree.
> The driver has been ported to latest linux-3.0-rc5 and
> net-2.6-353e5c9 tree.

It is a bit old. It could be better to rebase it against David Miller's
net-next tree as the drivers/net/ ethernet device tree has undergone
some changes.

The net-next tree is currently available at:

git://github.com/davem330/net-next.git

> The driver versions for 2.6.18 and 2.6.32 based kernel have been
> fully tested and released to the customer.  Shall I just send the
> driverxx.c and driverxx.h for net-2.6-353e5c9 and linux-3.0-rc5
> to this alias?

The remarks from 04/11 are still relevant but it will be a good start.

Did it went through internal reviewing by some usual Linux folks at
oracle (hint, hint) ?

-- 
Ueimor
