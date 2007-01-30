From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.20-rc5 1/4] atl1: unconditionally enable MSI
Date: Tue, 30 Jan 2007 09:41:32 -0500
Message-ID: <45BF591C.20701@garzik.org>
References: <20070128001004.GA10269@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: csnook@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, atl1-devel@lists.sourceforge.net,
	randy.dunlap@oracle.com, kronos.it@gmail.com
To: Jay Cliburn <jacliburn@bellsouth.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46219 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965372AbXA3Oll (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Jan 2007 09:41:41 -0500
In-Reply-To: <20070128001004.GA10269@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Cliburn wrote:
> From: Luca Tettamanti <kronos.it@gmail.com>
> 
> Unconditionally enable MSI in atl1 driver. Also remove some useless
> #ifdef since pci_{en,dis}able_msi() are no-op when MSI support is not
> configured in.
> 
> Signed-off-by: Luca Tettamanti <kronos.it@gmail.com>
> Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>

applied patches 1-4 to #atl1

The only remaining problem with your patches is that they added trailing 
whitespace:


[jgarzik@pretzel netdev-2.6]$ git-am --signoff --utf8 /g/tmp/mbox

Applying 'atl1: unconditionally enable MSI'

Adds trailing whitespace.
.dotest/patch:44:
warning: 1 line adds trailing whitespaces.
Wrote tree dc738e9c0b8becc628dc3bdbbcb02988b671065a
Committed: ab248491d6e576228710950e3d21ea0731aa2de4

Applying 'atl1: add missing include dma-mapping.h'

Wrote tree 5fb3cad9771ccb59d7e3610367bb69bb33b3b45d
Committed: 13b6ae2c23523e808530681e16998220150c881c

Applying 'atl1: properly use CONFIG_PM'

Wrote tree 9fb334ce776443d59039aaedcd6a5a09790a3d67
Committed: 01e8d5606f0732222baf9ec8664d1e833ac428ca

Applying 'atl1: incorporate reviewer comments'

Adds trailing whitespace.
.dotest/patch:197:static int atl1_get_settings(struct net_device *netdev,
Adds trailing whitespace.
.dotest/patch:230:static int atl1_set_settings(struct net_device *netdev,
Adds trailing whitespace.
.dotest/patch:240:              printk(KERN_DEBUG "%s: ethtool shutting 
down adapter\n",
Adds trailing whitespace.
.dotest/patch:258:                      } else
Adds trailing whitespace.
.dotest/patch:292:
warning: squelched 10 whitespace errors
warning: 15 lines add trailing whitespaces.
Wrote tree 75ab9e0e86a96951c542b1f6e7557c917ca6799b
Committed: 37e12a2bd50cb62add05b97fc6661d21782f232b

