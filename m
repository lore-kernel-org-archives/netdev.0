From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 4/4] atl1: Ancillary C files for Attansic L1 driver
Date: Tue, 23 Jan 2007 13:34:09 -0800
Message-ID: <20070123133409.17a32128@freekitty>
References: <20070121210737.GE2702@osprey.hogchain.net>
	<20070121183151.4be61ebf.randy.dunlap@oracle.com>
	<45B43093.6060500@bellsouth.net>
	<20070122200004.GA12553@dreamland.darkstar.lan>
	<20070123112522.65aac61b@freekitty>
	<45B67F29.4010703@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Luca Tettamanti <kronos.it@gmail.com>,
	Jay Cliburn <jacliburn@bellsouth.net>,
	Randy Dunlap <randy.dunlap@oracle.com>, shemminger@osdl.org,
	csnook@redhat.com, hch@infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, atl1-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:57900 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965488AbXAWVhO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Jan 2007 16:37:14 -0500
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <45B67F29.4010703@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 23 Jan 2007 16:33:29 -0500
Jeff Garzik <jeff@garzik.org> wrote:

> Stephen Hemminger wrote:
> > IMHO the MSI disabling should be removed from drivers and be done
> > in the PCI core.
> 
> That is the consensus opinion.
> 
> Currently drivers implement the MSI tests because the core PCI code 
> hasn't been up to snuff.  I (and others) have been discouraging that, 
> but when a user faces a choice between working and non-working network, 
> the pragmatic solution wins.
> 
> All efforts to get us to the point where we can remove the MSI tests 
> from drivers are strongly supported...
> 
> 	Jeff

So far, either MSI works for all devices or is broken, so it makes
sense to have a "msi=off" boot option (if there isn't already)

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
