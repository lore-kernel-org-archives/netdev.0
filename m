From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/4] mpls: Behaviour-changing improvements
Date: Mon, 06 Apr 2015 16:02:41 -0400 (EDT)
Message-ID: <20150406.160241.2301394902445905893.davem@davemloft.net>
References: <1426866170-28739-1-git-send-email-rshearma@brocade.com>
	<1427739356-28113-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com
To: rshearma@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48089 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753826AbbDFUCn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2015 16:02:43 -0400
In-Reply-To: <1427739356-28113-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Shearman <rshearma@brocade.com>
Date: Mon, 30 Mar 2015 19:15:52 +0100

> This series consists of several small changes to make it easier to
> understand the code, along with security and RFC-compliance
> changes. These are important to consider before userspace begins
> relying on the previous behaviour.
> 
> V2:
>   - Dropped PHP comment patch to avoid holding up the rest of the
>     changes due to quibbling on nomenclature.
>   - Corrected reference to RFC 3031 in commit message of patch
>     2. Added reference to RFC 3031 s4.1.5 for PHP behaviour.
>   - s/forwarding/input/ in patch 3.
>   - Made MPT_IPV4 and MPT_IPV6 equal to 4 and 6 respectively in patch
>     4, eliminating a switch on the version number as suggested by
>     review comments. Added back references to RFCs, but moved them to
>     mpls_payload_type enum declaration.
> V1:
>   - Updated to reference the correct RFC in the first patch.

Eric, I can't sit on this series much longer.  Please review this
at your next possible moment.

Thanks.
