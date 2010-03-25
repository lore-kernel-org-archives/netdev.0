From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [PATCH] e1000e: export some settings using ethtool private flags
Date: Thu, 25 Mar 2010 11:16:58 -0600
Message-ID: <EA929A9653AAE14F841771FB1DE5A1365FE4B3E5A7@rrsmsx501.amr.corp.intel.com>
References: <20100227082305.GA18194@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:22433 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752281Ab0CYRRA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Mar 2010 13:17:00 -0400
In-Reply-To: <20100227082305.GA18194@havoc.gtf.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Garzik wrote:
> The ethtool private flags interface exists to get/set driver-specific
> settings at runtime, in a flexible manner.
> 
> Use this facility to export a couple e1000e features, that were
> previously only set at module initialization time.
> 
> Signed-off-by: Jeff Garzik <jgarzik@redhat.com>
> ---
>  drivers/net/e1000e/ethtool.c |   27 +++++++++++++++++++++++++++
>  1 file changed, 27 insertions(+)

Jeff,

What is the use case for the ethtool private flags? At least I don't see an option in ethtool that would make use of them.

Thanks,
Emil
