From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] net: introduce a list of device addresses
 dev_addr_list
Date: Mon, 13 Apr 2009 15:54:36 -0700 (PDT)
Message-ID: <20090413.155436.230187370.davem@davemloft.net>
References: <20090413083729.GA23734@psychotron.englab.brq.redhat.com>
	<20090413084201.GC23734@psychotron.englab.brq.redhat.com>
	<20090413074917.4e317115@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jpirko@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jgarzik@pobox.com,
	bridge@lists.linux-foundation.org, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net, kaber@trash.net,
	mschmidt@redhat.com, dada1@cosmosbay.com, ivecera@redhat.com
To: shemminger@linux-foundation.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754549AbZDMWzA@vger.kernel.org>
In-Reply-To: <20090413074917.4e317115@nehalam>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Mon, 13 Apr 2009 07:49:17 -0700

> This lock is unnecessary, use RCU list for read.
> Since all changes are under RTNL mutex, there is no chance
> for conflict on update.

Agreed.
