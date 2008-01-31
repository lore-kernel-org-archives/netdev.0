From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: e1000 full-duplex TCP performance well below wire speed
Date: Thu, 31 Jan 2008 10:26:16 -0800
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F52044F9076@orsmsx418.amr.corp.intel.com>
References: <Pine.LNX.4.63.0801300324000.6391@trinity.phys.uwm.edu><20080130.055333.192844925.davem@davemloft.net><Pine.LNX.4.63.0801300758020.11487@trinity.phys.uwm.edu><20080130082136.1017631d@deepthought><Pine.LNX.4.63.0801301610240.19938@trinity.phys.uwm.edu><649aecc70801301617m6331bcb8i8ce60366e182c739@mail.gmail.com> <20080131064533.ef0ae932.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Bruce Allen" <ballen@gravity.phys.uwm.edu>,
	"Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>,
	"Stephen Hemminger" <shemminger@linux-foundation.org>
To: "Bill Fink" <billfink@mindspring.com>,
	"SANGTAE HA" <sangtae.ha@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:44663 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757102AbYAaS1v convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 13:27:51 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20080131064533.ef0ae932.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bill Fink wrote:
> a 2.6.15.4 kernel.  The GigE NICs are Intel PRO/1000
> 82546EB_QUAD_COPPER, 
> on a 64-bit/133-MHz PCI-X bus, using version 6.1.16-k2 of the e1000
> driver, and running with 9000-byte jumbo frames.  The TCP congestion
> control is BIC.

Bill, FYI, there was a known issue with e1000 (fixed in 7.0.38-k2) and
socket charge due to truesize that kept one end or the other from
opening its window.  The result is not so great performance, and you
must upgrade the driver at both ends to fix it.

it was fixed in commit
9e2feace1acd38d7a3b1275f7f9f8a397d09040e

That commit itself needed a couple of follow on bug fixes, but the point
is that you could download 7.3.20 from sourceforge (which would compile
on your kernel) and compare the performance with it if you were
interested in a further experiment.

Jesse
