From: David Miller <davem@davemloft.net>
Subject: Re: [patch 4/5] [PATCH] qeth: rework TSO functions
Date: Fri, 13 Nov 2009 20:36:21 -0800 (PST)
Message-ID: <20091113.203621.39740182.davem@davemloft.net>
References: <20091112101140.882313000@de.ibm.com>
	<20091112101301.126320000@de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: frank.blaschka@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46835
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757548AbZKNEgF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 23:36:05 -0500
In-Reply-To: <20091112101301.126320000@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: frank.blaschka@de.ibm.com
Date: Thu, 12 Nov 2009 11:11:44 +0100

> From: Frank Blaschka <frank.blaschka@de.ibm.com>
> 
> The maximum TSO size OSA can handle is 15 * PAGE_SIZE. This
> patch reduces gso_max_size to this value and adds some sanity
> checks and statistics to the TSO implementation.
> Since only layer 3 is able to do TSO move all TSO related functions
> to the qeth_l3 module.
> 
> Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>

Please don't add sysctl knobs for getting and setting TSO enabling,
that's what ethtool is for.
