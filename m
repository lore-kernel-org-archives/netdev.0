From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] Do not register ne2k-pci device until initialized
Date: Sat, 02 May 2009 13:05:34 -0400
Message-ID: <49FC7D5E.6050203@garzik.org>
References: <1241281735.2641.7.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	stable@kernel.org
To: Lubomir Rintel <lkundrak@v3.sk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52945 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752927AbZEBRFg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 May 2009 13:05:36 -0400
In-Reply-To: <1241281735.2641.7.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lubomir Rintel wrote:
> Doing it in reverse order causes uevent to be sent before
> we have a MAC address, which confuses udev.
> 
> Signed-off-by: Lubomir Rintel <lkundrak@v3.sk>

Acked-by: Jeff Garzik <jgarzik@redhat.com>

Good spotting, that fixes a clear startup race


