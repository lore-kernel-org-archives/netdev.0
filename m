From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH 5/6]: powerpc/cell spidernet bottom half
Date: Wed, 23 Aug 2006 16:52:46 -0500
Message-ID: <20060823215246.GH4401@austin.ibm.com>
References: <20060818220700.GG26889@austin.ibm.com> <20060818222657.GL26889@austin.ibm.com> <200608190103.05649.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linuxppc-dev@ozlabs.org, Jeff Garzik <jgarzik@pobox.com>,
	akpm@osdl.org, netdev@vger.kernel.org,
	James K Lewis <jklewis@us.ibm.com>,
	linux-kernel@vger.kernel.org,
	ens Osterkamp <Jens.Osterkamp@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:13778 "EHLO e4.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S965224AbWHWVwt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2006 17:52:49 -0400
To: Arnd Bergmann <arnd@arndb.de>
Content-Disposition: inline
In-Reply-To: <200608190103.05649.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Aug 19, 2006 at 01:03:04AM +0200, Arnd Bergmann wrote:
> using the NAPI poll function

Still fiddling with this. Getting side-tracked after noticing
that the RX side generates a *huge* numbe of interrupts, despite
code in the driver which superficially appears to be RX NAPI.  
One step forward, two steps back, isn't there a dance like that?

--linas
