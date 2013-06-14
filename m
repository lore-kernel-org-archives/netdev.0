From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net-next v3 0/4] Some SCTP cleanups/improvements
Date: Fri, 14 Jun 2013 13:00:54 -0400
Message-ID: <51BB4C46.2080506@gmail.com>
References: <1371227047-16852-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f176.google.com ([209.85.220.176]:39289 "EHLO
	mail-vc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752035Ab3FNRA6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jun 2013 13:00:58 -0400
In-Reply-To: <1371227047-16852-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/14/2013 12:24 PM, Daniel Borkmann wrote:
> v2 -> v3:
>    - Applied feedback from Vlad in first patch, rest is unchanged
>
> v1 -> v2:
>    - Applied Neil's feedback, I'll send out the first patch at a later
>      point in time though, have not included it in this set
>    - Add two other patches that appear to be useful from the last
>      couple of days debugging SCTP code
>
> Let it run through lksctp-tools and also my recent stress test tool,
> all looks good.

Looks good.

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

>
> Daniel Borkmann (4):
>    net: sctp: sideeffect: throw BUG if primary_path is NULL
>    net: sctp: sctp_sf_do_prm_asoc: do SCTP_CMD_INIT_CHOOSE_TRANSPORT first
>    net: sctp: minor: remove variable in sctp_init_sock
>    net: sctp: sctp_association_init: put refs in reverse order
>
>   net/sctp/associola.c     |  7 +++----
>   net/sctp/proc.c          | 19 ++++++++++++++++---
>   net/sctp/sm_sideeffect.c |  5 ++++-
>   net/sctp/sm_statefuns.c  |  8 ++++----
>   net/sctp/socket.c        |  6 ++----
>   5 files changed, 29 insertions(+), 16 deletions(-)
>
