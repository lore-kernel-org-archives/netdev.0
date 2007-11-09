From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH 2/2]: e1000: avoid lockup durig error recovery
Date: Fri, 9 Nov 2007 16:40:05 -0600
Message-ID: <20071109224005.GQ4239@austin.ibm.com>
References: <20071107211935.GH4239@austin.ibm.com> <47323FFE.2060008@intel.com> <20071107232119.GQ4239@austin.ibm.com> <200711091802.36365.netdev@axxeo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>, wenxiong@us.ibm.com,
	e1000-devel@lists.sourceforge.net,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	john.ronciak@intel.com, jeffrey.t.kirsher@intel.com,
	Jeff Garzik <jeff@garzik.org>, NetDev <netdev@vger.kernel.org>,
	"'Stephen Hemminger'" <shemminger@linux-foundation.org>
To: Ingo Oeser <netdev@axxeo.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:57401 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751130AbXKIWkP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Nov 2007 17:40:15 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lA9MfhRV031544
	for <netdev@vger.kernel.org>; Fri, 9 Nov 2007 17:41:43 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.6) with ESMTP id lA9Me67s127762
	for <netdev@vger.kernel.org>; Fri, 9 Nov 2007 17:40:06 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lA9Me5tw022071
	for <netdev@vger.kernel.org>; Fri, 9 Nov 2007 17:40:06 -0500
Content-Disposition: inline
In-Reply-To: <200711091802.36365.netdev@axxeo.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 09, 2007 at 06:02:34PM +0100, Ingo Oeser wrote:
> Linas Vepstas schrieb:
> > + *	napi_enabled_p - return non-zero if napi enabled
> > + * 
> > + * Mnemonic: _p stands for "predicate", returning a yes/no
> > + * answer to the question.
> 
> Call it "is_napi_enabled()" an nobody will ask :-)

Heh. The suffix _p is standard coding style for lisp/scheme
and first-order logic interpreters.  This was my lame attempt
to introduce it to the kernel. I guess that lame duck won't fly.

--linas

