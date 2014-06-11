From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH v3 net-next 0/5] SCTP update
Date: Wed, 11 Jun 2014 12:24:32 -0400
Message-ID: <539882C0.3000209@gmail.com>
References: <1402503572-32237-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f173.google.com ([209.85.216.173]:63269 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755753AbaFKQYf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 12:24:35 -0400
In-Reply-To: <1402503572-32237-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/11/2014 12:19 PM, Daniel Borkmann wrote:
> This set contains transport path selection improvements in
> SCTP. Please see individual patches for details.
> 
> Thanks!
> 
> v2->v3:
>  - Reworded commit message in patch 4, thanks Vlad!
> v1->v2:
>  - Fixed a typo in a comment in patch 1, thanks Florian Westphal
>    for pointing this out, rest stays as is.
> 
> Daniel Borkmann (5):
>   ktime: add ktime_after and ktime_before helper
>   net: sctp: refactor active path selection
>   net: sctp: migrate most recently used transport to ktime
>   net: sctp: improve sctp_select_active_and_retran_path selection
>   net: sctp: fix incorrect type in gfp initializer
> 

Series
Acked-by: Vlad Yasevich <vyasevich@gmail.com>


Thanks
-vlad

>  include/linux/ktime.h      |  24 +++++++
>  include/net/sctp/structs.h |   6 +-
>  net/sctp/associola.c       | 168 ++++++++++++++++++++++++++++-----------------
>  net/sctp/endpointola.c     |   2 +-
>  net/sctp/sm_make_chunk.c   |   2 +-
>  net/sctp/transport.c       |   2 +-
>  6 files changed, 136 insertions(+), 68 deletions(-)
> 
