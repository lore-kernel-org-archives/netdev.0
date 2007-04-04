From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 3/4] 8139too: RTNL and flush_scheduled_work deadlock
Date: Wed, 04 Apr 2007 16:38:44 -0700
Message-ID: <46143704.7020802@candelatech.com>
References: <20070215223744.GC19840@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	Kyle Lucke <klucke@us.ibm.com>,
	Raghavendra Koushik <raghavendra.koushik@neterion.com>,
	Al Viro <viro@ftp.linux.org.uk>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:41055 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752843AbXDDXjm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Apr 2007 19:39:42 -0400
In-Reply-To: <20070215223744.GC19840@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Your usual dont-flush_scheduled_work-with-RTNL-held stuff.
> 
> It is a bit different here since the thread runs permanently
> or is only occasionally kicked for recovery depending on the
> hardware revision.

It looks like this has not made it into the 2.6.20 stable series
patches...  Any reason not to add it there?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

