From: Roland Dreier <rdreier@cisco.com>
Subject: Re: IPoIB: Fix multicast packet drops before join is complete
Date: Fri, 05 Jun 2009 14:13:25 -0700
Message-ID: <adabpp2v0y2.fsf@cisco.com>
References: <alpine.DEB.1.10.0906021044430.15692@gentwo.org>
	<20090603.224104.222901210.davem@davemloft.net>
	<alpine.DEB.1.10.0906041150590.3204@gentwo.org>
	<20090604.153057.178458221.davem@davemloft.net>
	<alpine.DEB.1.10.0906050959380.23895@gentwo.org>
	<adaeitywrfj.fsf@cisco.com>
	<alpine.DEB.1.10.0906051444360.29918@gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	yosefe@Voltaire.COM
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:36711 "EHLO
	sj-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752454AbZFEVWv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jun 2009 17:22:51 -0400
In-Reply-To: <alpine.DEB.1.10.0906051444360.29918@gentwo.org> (Christoph
	Lameter's message of "Fri, 5 Jun 2009 15:17:26 -0400 (EDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


 > This is actually better than IPoIB there is nothing before
 > the initial traffic that arrives. In the IPoIB case 3 packets arrive
 > suggesting to the other side that the link is okay.

So maybe we should drop the *oldest* packet on queue overflow?  Would
that make things better?

 - R.
