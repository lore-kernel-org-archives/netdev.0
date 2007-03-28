From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] atl1: remove unnecessary crc inversion
Date: Wed, 28 Mar 2007 02:19:53 -0400
Message-ID: <460A0909.8000607@garzik.org>
References: <20070328004349.GA2792@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: csnook@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jareguero@telefonica.net,
	atl1-devel@lists.sourceforge.net
To: Jay Cliburn <jacliburn@bellsouth.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:42353 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933604AbXC1GT4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Mar 2007 02:19:56 -0400
In-Reply-To: <20070328004349.GA2792@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Cliburn wrote:
> From: Jay Cliburn <jacliburn@bellsouth.net>
> 
> The original vendor driver contained a private ether_crc_le() function
> that produced an inverted crc.  When we changed to the kernel version of
> ether_crc_le(), we neglected to undo the inversion.  Let's do it now.
> Discovered by and patch proffered by Jose Alberto Reguero.
> 
> Signed-off-by: Jose Alberto Reguero <jareguero@telefonica.net>
> Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>

applied to #upstream-fixes


