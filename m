From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH v2 0/3] mpls: ABI changes for security and correctness
Date: Wed, 22 Apr 2015 11:47:10 -0500
Message-ID: <87wq14jek1.fsf@x220.int.ebiederm.org>
References: <1429648467-8449-1-git-send-email-rshearma@brocade.com>
	<1429697679-13767-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:38452 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965979AbbDVQvc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 12:51:32 -0400
In-Reply-To: <1429697679-13767-1-git-send-email-rshearma@brocade.com> (Robert
	Shearman's message of "Wed, 22 Apr 2015 11:14:36 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Robert Shearman <rshearma@brocade.com> writes:

> V2:
>  - don't treat loopback interfaces specially by enabling mpls by
>    default
>
> These changes make mpls not be enabled by default on all
> interfaces when in use for security, along with ensuring that a label
> not valid as an outgoing label can be added in mpls routes.
>
> This series contains three ABI/behaviour-affecting changes which have
> been split out from "[PATCH net-next v4 0/6] mpls: Behaviour-changing
> improvements" without any further modification. These changes need to
> be considered for 4.1 otherwise we'll be stuck with the current
> behaviour/ABI forever.

Thanks.

Reviewed-by: "Eric W. Biederman" <ebiederm@xmission.com>

These patches all look good.  If these patches can make it into 4.1 so
we don't have a stable release without the new net/mpls/conf/<dev>/input
sysctl that would minimize disruption to users of the mpls code.

Eric

> Robert Shearman (3):
>   mpls: Per-device MPLS state
>   mpls: Per-device enabling of packet input
>   mpls: Prevent use of implicit NULL label as outgoing label
>
>  Documentation/networking/mpls-sysctl.txt |   9 +++
>  include/linux/netdevice.h                |   4 +
>  net/mpls/af_mpls.c                       | 125 ++++++++++++++++++++++++++++++-
>  net/mpls/internal.h                      |   6 ++
>  4 files changed, 141 insertions(+), 3 deletions(-)
