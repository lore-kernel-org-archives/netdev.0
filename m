From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 0/3] mpls: ABI changes for security and correctness
Date: Tue, 21 Apr 2015 19:29:42 -0500
Message-ID: <87d22xm2dl.fsf@x220.int.ebiederm.org>
References: <1429051503-31287-1-git-send-email-rshearma@brocade.com>
	<1429648467-8449-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:55846 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932209AbbDVAd6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2015 20:33:58 -0400
In-Reply-To: <1429648467-8449-1-git-send-email-rshearma@brocade.com> (Robert
	Shearman's message of "Tue, 21 Apr 2015 21:34:24 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Robert Shearman <rshearma@brocade.com> writes:

> These changes make mpls not be enabled by default on all
> interfaces when in use for security, along with ensuring that a label
> not valid as an outgoing label can be added in mpls routes.
>
> This series contains three ABI/behaviour-affecting changes which have
> been split out from "[PATCH net-next v4 0/6] mpls: Behaviour-changing
> improvements" without any further modification. These changes need to
> be considered for 4.1 otherwise we'll be stuck with the current
> behaviour/ABI forever.

I don't like the difference in default between loopback and everything
else.  That just seems like an extra arbitrary rule.

Otherwise:
Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>

Not that I expect Dave Miller is taking patches during the merge window.

> Robert Shearman (3):
>   mpls: Per-device MPLS state
>   mpls: Per-device enabling of packet input
>   mpls: Prevent use of implicit NULL label as outgoing label
>
>  Documentation/networking/mpls-sysctl.txt |   9 +++
>  include/linux/netdevice.h                |   4 +
>  net/mpls/af_mpls.c                       | 132 ++++++++++++++++++++++++++++++-
>  net/mpls/internal.h                      |   6 ++
>  4 files changed, 148 insertions(+), 3 deletions(-)

Eric
