From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: e100: Wait for PHY reset to complete?
Date: Wed, 25 Oct 2006 23:57:09 +0200
Message-ID: <20061025215709.GA18507@electric-eye.fr.zoreil.com>
References: <453F9D4A.8090306@users.sourceforge.net> <20061025185656.GA19037@electric-eye.fr.zoreil.com> <453FC693.10705@intel.com> <453FD677.7060405@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Anders Grafstrom <grfstrm@users.sourceforge.net>,
	netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:31390 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1751215AbWJYV7p
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Oct 2006 17:59:45 -0400
To: Auke Kok <auke-jan.h.kok@intel.com>
Content-Disposition: inline
In-Reply-To: <453FD677.7060405@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok <auke-jan.h.kok@intel.com> :
[...]
> okay, I don't think this is needed at all:
> 
> Allthough the spec itself didn't talk about phy reset times, I've ran this 
> patch with some debugging output on a few boxes and did some speed/duplex 
> settings, and the PHY reset returned succesfull after the very first 
> mdio_read, which is before any msleep(10) is executed. That is also 
> expected behaviour.

Would it be expected as well that the PHY has performed reset before the
second mdio_write hits it when the mdio_read is not there at all ?

-- 
Ueimor
