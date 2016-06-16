From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [net-next PATCH v3 01/17] vxlan/geneve: Include udp_tunnel.h in
 vxlan/geneve.h and fixup includes
Date: Fri, 17 Jun 2016 01:06:04 +0200
Message-ID: <4dd0dfc3-bd95-6559-ab53-1cf462d3c914@stressinduktion.org>
References: <20160616191851.20872.67154.stgit@localhost.localdomain>
 <20160616192044.20872.17936.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: jesse@kernel.org, eugenia@mellanox.com, jbenc@redhat.com,
	alexander.duyck@gmail.com, saeedm@mellanox.com,
	ariel.elior@qlogic.com, tom@herbertland.com,
	michael.chan@broadcom.com, Dept-GELinuxNICDev@qlogic.com,
	davem@davemloft.net
To: Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:45687 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751711AbcFPXGK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 19:06:10 -0400
In-Reply-To: <20160616192044.20872.17936.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16.06.2016 21:20, Alexander Duyck wrote:
> This patch makes it so that we add udp_tunnel.h to vxlan.h and geneve.h
> header files.  This is useful as I plan to move the generic handlers for
> the port offloads into the udp_tunnel header file and leave the vxlan and
> geneve headers to be a bit more protocol specific.
> 
> I also went through and cleaned out a number of redundant includes that
> where in the .h and .c files for these drivers.
> 
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>

Also,

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
