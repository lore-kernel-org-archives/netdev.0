From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCH v4 for-next 00/12] Add network namespace support in the
 RDMA-CM
Date: Thu, 28 May 2015 09:46:33 -0600
Message-ID: <20150528154633.GB2962@obsidianresearch.com>
References: <1431841868-28063-1-git-send-email-haggaie@mellanox.com>
 <1432647280.28905.107.camel@redhat.com>
 <20150526165928.GC11800@obsidianresearch.com>
 <1432662396.28905.157.camel@redhat.com>
 <5567169C.60206@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Doug Ledford <dledford@redhat.com>, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, Liran Liss <liranl@mellanox.com>,
	Guy Shapiro <guysh@mellanox.com>,
	Shachar Raindel <raindel@mellanox.com>,
	Yotam Kenneth <yotamke@mellanox.com>
To: Haggai Eran <haggaie@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:49725 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754182AbbE1Pqe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2015 11:46:34 -0400
Content-Disposition: inline
In-Reply-To: <5567169C.60206@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 28, 2015 at 04:22:36PM +0300, Haggai Eran wrote:
> wouldn't care if they share the "QP number namespace", etc. RDMA CM
> ports are different because they are chosen by the applications, but
> they map directly to the network namespace, so they don't require their
> own namespace.

Different containers should have restricted access to the PKey and GID
tables, and the presence device itself. Just like in the SRIOV
case.

That is what the 'RDMA Namespace' would control.

Jason
