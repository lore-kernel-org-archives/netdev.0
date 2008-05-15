From: Cornelia Huck <cornelia.huck@de.ibm.com>
Subject: Re: [PATCH 2/3] sysfs: remove error messages for -EEXIST case
Date: Thu, 15 May 2008 12:06:19 +0200
Message-ID: <20080515120619.6c867bfb@gondolin.boeblingen.de.ibm.com>
References: <20080515095246.3b6a0d1d@gondolin.boeblingen.de.ibm.com>
	<20080515.010139.219194657.davem@davemloft.net>
	<20080515113131.2cea2bce@gondolin.boeblingen.de.ibm.com>
	<20080515.030054.247673168.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, greg@kroah.com, fubar@us.ibm.com,
	netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.de.ibm.com ([195.212.29.157]:45985 "EHLO
	mtagate8.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752318AbYEOKIu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2008 06:08:50 -0400
In-Reply-To: <20080515.030054.247673168.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 15 May 2008 03:00:54 -0700 (PDT),
David Miller <davem@davemloft.net> wrote:

> No, the idea is that the __sysfs_add_one() wouldn't need a parameter
> at all.  sysfs_add_one() just needs to check for -EEXIST from
> __sysfs_add_one() to decide whether to warn or not.

But that is what the patch does? Only the upper layers need to pass a
flag around.
