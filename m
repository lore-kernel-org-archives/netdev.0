From: Christoph Lameter <cl@linux.com>
Subject: Re:
Date: Tue, 28 Sep 2010 10:49:25 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1009281007130.6360@router.home>
References: <20100927200500.GB25879@obsidianresearch.com> <OF056C7E7C.A9A5EFC7-ON882577AB.006E6B89-882577AB.006F2C1E@us.ibm.com> <alpine.DEB.2.00.1009271521510.14117@router.home> <OF980F8B87.D755A28E-ON882577AB.00779881-882577AB.0077F27A@us.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
	linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>, Bob Arendt <rda@rincon.com>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp110.prem.mail.ac4.yahoo.com ([76.13.13.93]:32307 "HELO
	smtp110.prem.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750941Ab0I1Pt3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Sep 2010 11:49:29 -0400
In-Reply-To: <OF980F8B87.D755A28E-ON882577AB.00779881-882577AB.0077F27A@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 27 Sep 2010, David Stevens wrote:

>         No. I'm not talking about the force_igmp_tunable here, I'm talking
> about the per-interface robustness and interval settings which come from
> the querier (whatever version you are using).

The igmp subsystem currently does not keep state on the interface layer
about robustness etc. An interval setting is only kept for IGMP v3 and
used only for general query timeouts with igmp V3. The interval is
different one from the one used for the host membership reports.

Looking at the spec I get the impression that these variables seems to be
mainly of interest to router to router communications?



