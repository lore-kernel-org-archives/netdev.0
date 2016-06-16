From: Hannes Frederic Sowa <hsowa@redhat.com>
Subject: Re: [net-next PATCH v3 16/17] net: Remove deprecated tunnel specific
 UDP offload functions
Date: Fri, 17 Jun 2016 00:59:53 +0200
Message-ID: <b1786c31-f09e-104d-0410-d4f85bbe85b8@redhat.com>
References: <20160616191851.20872.67154.stgit@localhost.localdomain>
 <20160616192312.20872.19285.stgit@localhost.localdomain>
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
Received: from mx1.redhat.com ([209.132.183.28]:47231 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753864AbcFPXAA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jun 2016 19:00:00 -0400
In-Reply-To: <20160616192312.20872.19285.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16.06.2016 21:23, Alexander Duyck wrote:
> Now that we have all the drivers using udp_tunnel_get_rx_ports,
> ndo_add_udp_enc_rx_port, and ndo_del_udp_enc_rx_port we can drop the
> function calls that were specific to VXLAN and GENEVE.
> 
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Also thanks for cleaning the Kconfig dust from all the drivers!
