From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/4] mpls: Behaviour-changing improvements
Date: Wed, 01 Apr 2015 15:30:41 -0400 (EDT)
Message-ID: <20150401.153041.376950284605107486.davem@davemloft.net>
References: <1426866170-28739-1-git-send-email-rshearma@brocade.com>
	<1427739356-28113-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com
To: rshearma@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60161 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753225AbbDATao (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 15:30:44 -0400
In-Reply-To: <1427739356-28113-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Shearman <rshearma@brocade.com>
Date: Mon, 30 Mar 2015 19:15:52 +0100

> This series consists of several small changes to make it easier to
> understand the code, along with security and RFC-compliance
> changes. These are important to consider before userspace begins
> relying on the previous behaviour.

Robert, you _absolutely_ must give common courtesy to Eric Biederman
and always CC: him explicitly on any proposed changes you want to make
to the new MPLS support.

I'm adding him here.

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
> 
> Robert Shearman (4):
>   mpls: Use definition for reserved label checks
>   mpls: Differentiate implicit-null and unlabeled neighbours
>   mpls: Per-device enabling of packet input
>   mpls: Allow payload type to be associated with label routes
> 
>  Documentation/networking/mpls-sysctl.txt |   9 ++
>  include/linux/netdevice.h                |   4 +
>  net/mpls/af_mpls.c                       | 226 +++++++++++++++++++++++++------
>  net/mpls/internal.h                      |   7 +
>  4 files changed, 203 insertions(+), 43 deletions(-)
> 
> -- 
> 2.1.4
> 
