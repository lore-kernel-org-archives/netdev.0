From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH] netxen: Error return off by one in
 'netxen_nic_set_pauseparam()'.
Date: Wed, 20 Jun 2012 10:44:47 +0300
Message-ID: <20120620074447.GS4400@mwanda>
References: <1340177259-14083-1-git-send-email-santoshprasadnayak@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sony.chacko@qlogic.com, rajesh.borundia@qlogic.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: santosh nayak <santoshprasadnayak@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:27990 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752367Ab2FTHpD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2012 03:45:03 -0400
Content-Disposition: inline
In-Reply-To: <1340177259-14083-1-git-send-email-santoshprasadnayak@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 20, 2012 at 12:57:39PM +0530, santosh nayak wrote:
> From: Santosh Nayak <santoshprasadnayak@gmail.com>
> 
> There are 'NETXEN_NIU_MAX_GBE_PORTS'  GBE ports. Port indexing starts
> from zero. 
> Hence we should also return error for "port == NETXEN_NIU_MAX_GBE_PORTS"
> 

I don't know this code well enough to say if you are right or not,
but what about for port == NETXEN_NIU_MAX_XG_PORTS a few lines later
in both functions?

regards,
dan carpenter
