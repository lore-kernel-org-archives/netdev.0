From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Do not register ne2k-pci device until initialized
Date: Sat, 02 May 2009 13:52:49 -0700 (PDT)
Message-ID: <20090502.135249.22146598.davem@davemloft.net>
References: <1241281735.2641.7.camel@localhost.localdomain>
	<49FC7D5E.6050203@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lkundrak@v3.sk, netdev@vger.kernel.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, stable@kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55492
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758604AbZEBUwy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 May 2009 16:52:54 -0400
In-Reply-To: <49FC7D5E.6050203@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Garzik <jeff@garzik.org>
Date: Sat, 02 May 2009 13:05:34 -0400

> Lubomir Rintel wrote:
>> Doing it in reverse order causes uevent to be sent before
>> we have a MAC address, which confuses udev.
>> Signed-off-by: Lubomir Rintel <lkundrak@v3.sk>
> 
> Acked-by: Jeff Garzik <jgarzik@redhat.com>
> 
> Good spotting, that fixes a clear startup race

Applied, thanks.
