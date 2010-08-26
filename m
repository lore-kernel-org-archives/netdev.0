From: Christoph Lameter <cl@linux.com>
Subject: Re: [IPoIB] Identify multicast packets and fix IGMP breakage V3
Date: Thu, 26 Aug 2010 18:57:09 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1008261856090.29657@router.home>
References: <adapqx5rtez.fsf@cisco.com> <alpine.DEB.2.00.1008261613160.24174@router.home> <alpine.DEB.2.00.1008261629440.24174@router.home> <20100826.151553.242147157.davem@davemloft.net> <20100826222146.GA23025@obsidianresearch.com>
 <alpine.DEB.2.00.1008261825490.26351@router.home> <20100826234342.GA24333@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: rdreier@cisco.com, linux-rdma@vger.kernel.org,
	ogerlitz@voltaire.com, yosefe@voltaire.com, netdev@vger.kernel.org
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp102.prem.mail.ac4.yahoo.com ([76.13.13.41]:48178 "HELO
	smtp102.prem.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753906Ab0HZX5N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Aug 2010 19:57:13 -0400
In-Reply-To: <20100826234342.GA24333@obsidianresearch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 26 Aug 2010, Jason Gunthorpe wrote:

> I think doing the memcmp only in the multicast path should be
> reasonable overhead wise.

Thats is not always possible. Here the multicast path is the
default path that is taken 99% of the time.

