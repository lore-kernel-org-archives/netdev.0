From: Joerg Roedel <joro-lkml@zlug.org>
Subject: Re: [PATCH 01/02 V3] net/ipv6: seperate sit driver to extra module
Date: Sat, 14 Oct 2006 11:32:55 +0200
Message-ID: <20061014093255.GA4646@zlug.org>
References: <20061010153745.GA27455@zlug.org> <452FD6F6.3090907@l4x.org> <20061013191744.GA30089@zlug.org> <20061013.150608.63128976.davem@davemloft.net> <45301CB3.4060803@l4x.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ironport-c10.fh-zwickau.de ([141.32.72.200]:44892 "EHLO
	ironport-c10.fh-zwickau.de") by vger.kernel.org with ESMTP
	id S1161086AbWJNJc7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Oct 2006 05:32:59 -0400
To: Jan Dittmer <jdi@l4x.org>
Content-Disposition: inline
In-Reply-To: <45301CB3.4060803@l4x.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 14, 2006 at 01:09:39AM +0200, Jan Dittmer wrote:
> David Miller wrote:
> > From: Joerg Roedel <joro-lkml@zlug.org>
> > Date: Fri, 13 Oct 2006 21:17:45 +0200
> > 
> >> On Fri, Oct 13, 2006 at 08:12:06PM +0200, Jan Dittmer wrote:
> >>> This is missing the MODULE_LICENSE statements and taints the kernel upon
> >>> loading. License is obvious from the beginning of the file.
> >  ...
> >>> Signed-off-by: Jan Dittmer <jdi@l4x.org>
> >> Signed-off-by: Joerg Roedel <joro-lkml@zlug.org>
> > 
> > Applied, thanks for catching this Jan.
> > 
> 
> Btw. is there any way to autoload the sit module or is this the
> task of the distribution tools? Debian etch at least does not
> automatically probe the module when trying to bring up a 6to4 tunnel.

AFAIK there is no way to automatically load the driver from the kernel
space. The configuration of the tunnel devices requires the sit0 device.
But this device is installed by the sit driver. I mailed a bug report to
the Debian people and informed them about the change.

Joerg
