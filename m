From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [ewg] [PATCH 13/14] nes: kernel build infrastructure
Date: Thu, 09 Aug 2007 10:32:51 -0700
Message-ID: <adaabt0obp8.fsf@cisco.com>
References: <200708080123.l781NpKJ004903@neteffect.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, ewg@lists.openfabrics.org
To: ggrundstrom@neteffect.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:64739 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761864AbXHIRcw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2007 13:32:52 -0400
In-Reply-To: <200708080123.l781NpKJ004903@neteffect.com> (ggrundstrom@neteffect.com's message of "Tue, 7 Aug 2007 20:23:51 -0500")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > +config INFINIBAND_NES
 > +	tristate "NetEffect RNIC Driver"
 > +	depends on PCI && INET && INFINIBAND

You don't need the dependency on INFINIBAND any more, because the
whole drivers/infiniband/Kconfig file is guarded by an "if INFINIBAND"

 - R.
