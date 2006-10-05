From: Joerg Roedel <joro-lkml@zlug.org>
Subject: Re: [PATCH][RFC] net/ipv6: seperate sit driver to extra module
Date: Thu, 5 Oct 2006 17:59:53 +0200
Message-ID: <20061005155953.GB2102@zlug.org>
References: <20061005154152.GA2102@zlug.org> <Pine.LNX.4.64.0610051148230.23631@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ironport-c10.fh-zwickau.de ([141.32.72.200]:23194 "EHLO
	ironport-c10.fh-zwickau.de") by vger.kernel.org with ESMTP
	id S1751651AbWJEP7z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Oct 2006 11:59:55 -0400
To: James Morris <jmorris@namei.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0610051148230.23631@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 05, 2006 at 11:49:38AM -0400, James Morris wrote:
> On Thu, 5 Oct 2006, Joerg Roedel wrote:
> 
> > Is there a reason why the tunnel driver for IPv6-in-IPv4 is currently
> > compiled into the ipv6 module? This driver is only needed in gateways
> > between different IPv6 networks. On all other hosts with ipv6 enabled it
> > is not required. To have this driver in a seperate module will save
> > memory on those machines.
> > I appended a small and trival patch to 2.6.18 which does exactly this.
> 
> Looks ok to me, although given that users used to get this by default when 
> selecting IPv6, perhaps the default in Kconfig should be y.

Ok, a good point to write y there. I change this. I wrote n there
because of the "If unsure, say N" sentence in the description.

Joerg
