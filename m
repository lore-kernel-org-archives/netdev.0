From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Re: [patch 03/14] e1000: omit stats for broken counter in 82543
Date: Fri, 15 Dec 2006 15:33:03 +0100
Message-ID: <4582B21F.8090907@linux.intel.com>
References: <1166174907.3365.108.camel@laptopd505.fenrus.org> <1166175100.3365.115.camel@laptopd505.fenrus.org> <4582B17D.3070500@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:37751 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752671AbWLOOmt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Dec 2006 09:42:49 -0500
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <4582B17D.3070500@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Needs to use an "i have broken stats" feature flag, rather than adding 
> yet another mac_type test into the code.  This testing of MAC type 
> rather than feature flags is a major e1000 problem, and it bloats the 
> driver quite a bit.  Intel has been told for /months/ this is a problem, 
> yet I still see patches like this.
> 
it is "nice" that you say this, and Intel is working on a "flags" 
based driver. However that is, as you state yourself here, a major 
invasive change, and thus not suitable for 2.6.20 inclusion. Yet these 
fixes are important bugfixes; I don't think it's fair to hold these 
hostage..

Greetings,
   Arjan van de Ven
