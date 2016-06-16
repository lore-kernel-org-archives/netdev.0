From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [net-next PATCH v3 17/17] vxlan: Add new UDP encapsulation
 offload type for VXLAN-GPE
Date: Fri, 17 Jun 2016 01:01:38 +0200
Message-ID: <cd97e62f-9513-99c6-3f47-d849b268ef17@stressinduktion.org>
References: <20160616191851.20872.67154.stgit@localhost.localdomain>
 <20160616192318.20872.40266.stgit@localhost.localdomain>
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
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:48639 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753900AbcFPXBn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 19:01:43 -0400
In-Reply-To: <20160616192318.20872.40266.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16.06.2016 21:23, Alexander Duyck wrote:
> The fact is VXLAN with Generic Protocol Extensions cannot be supported by
> the same hardware parsers that support VXLAN.  The protocol extensions
> allow for things like a Next Protocol field which in turn allows for things
> other than Ethernet to be passed over the tunnel.  Most existing parsers
> will not know how to interpret this.
> 
> To resolve this I am giving VXLAN-GPE its own UDP encapsulation offload
> type.  This way hardware that does support GPE can simply add this type to
> the switch statement for VXLAN, and if they don't support it then this will
> fix any issues where headers might be interpreted incorrectly.
> 
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
