From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 0/4] bonding: fix module multiple load issues
Date: Sat, 20 Jan 2007 12:22:39 +0100
Message-ID: <45B1FB7F.4060204@trash.net>
References: <200701200215.l0K2FF22021615@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net,
	Jeff Garzik <jgarzik@pobox.com>, mitch.a.williams@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48342 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965253AbXATLWt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Jan 2007 06:22:49 -0500
To: Jay Vosburgh <fubar@us.ibm.com>
In-Reply-To: <200701200215.l0K2FF22021615@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Vosburgh wrote:
> 	Patch 1: fix device name allocation error
> 	Patch 2: fix error check in sysfs creation
> 	Patch 3: modify sysfs support to permit multiple loads
> 	Patch 4: update version number
> 
> 	This patch series should resolve whatever problems there are
> with the logic to load the module multiple times.  This code changed
> during the introduction of sysfs, and some recent tightening of the
> sysfs creation code (checking for duplicates) broke that.
> 
> 	The multiple load logic is used primarily by the initscripts and
> sysconfig packages, to automatically configure multiple bonding
> interfaces at boot time.
> 
> 	Originally reported by Patrick McHardy <kaber@trash.net>.

Confirmed to fix the problems I was seeing, thanks.
