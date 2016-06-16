From: Hannes Frederic Sowa <hannes@redhat.com>
Subject: Re: [net-next PATCH v3 03/17] net: Merge VXLAN and GENEVE push
 notifiers into a single notifier
Date: Fri, 17 Jun 2016 00:47:30 +0200
Message-ID: <ca1aecfd-ca23-e8ce-aa21-8a6a99a59c03@redhat.com>
References: <20160616191851.20872.67154.stgit@localhost.localdomain>
 <20160616192100.20872.88358.stgit@localhost.localdomain>
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
Received: from mx1.redhat.com ([209.132.183.28]:55972 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753864AbcFPWri (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jun 2016 18:47:38 -0400
In-Reply-To: <20160616192100.20872.88358.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16.06.2016 21:21, Alexander Duyck wrote:
> This patch merges the notifiers for VXLAN and GENEVE into a single UDP
> tunnel notifier.  The idea is that we will want to only have to make one
> notifier call to receive the list of ports for VXLAN and GENEVE tunnels
> that need to be offloaded.
> 
> In addition we add a new set of ndo functions named ndo_udp_tunnel_add and
> ndo_udp_tunnel_del that are meant to allow us to track the tunnel meta-data
> such as port and address family as tunnels are added and removed.  The
> tunnel meta-data is now transported in a structure named udp_tunnel_info
> which for now carries the type, address family, and port number.  In the
> future this could be updated so that we can include a tuple of values
> including things such as the destination IP address and other fields.
> 
> I also ended up going with a naming scheme that consisted of using the
> prefix udp_tunnel on function names.  I applied this to the notifier and
> ndo ops as well so that it hopefully points to the fact that these are
> primarily used in the udp_tunnel functions.
> 
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
