From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [net-next PATCH v3 02/17] net: Combine GENEVE and VXLAN port
 notifiers into single functions
Date: Fri, 17 Jun 2016 00:45:50 +0200
Message-ID: <d3bb41cb-3d1f-bcf2-7951-46e655d2ea94@stressinduktion.org>
References: <20160616191851.20872.67154.stgit@localhost.localdomain>
 <20160616192052.20872.92437.stgit@localhost.localdomain>
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
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:46734 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753864AbcFPWp4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 18:45:56 -0400
In-Reply-To: <20160616192052.20872.92437.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16.06.2016 21:20, Alexander Duyck wrote:
> This patch merges the GENEVE and VXLAN code so that both functions pass
> through a shared code path.  This way we can start the effort of using a
> single function on the network device drivers to handle both of these
> tunnel types.
> 
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
