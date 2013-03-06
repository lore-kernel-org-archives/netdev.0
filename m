From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCHv2 iproute2 0/3] Bridge VLAN support
Date: Wed, 06 Mar 2013 11:26:51 -0500
Message-ID: <51376E4B.4060605@redhat.com>
References: <1362081846-25268-1-git-send-email-vyasevic@redhat.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64981 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750762Ab3CFQ0y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Mar 2013 11:26:54 -0500
In-Reply-To: <1362081846-25268-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/28/2013 03:04 PM, Vlad Yasevich wrote:
> This series adds VLAN configuration to the bridge command.  With this
> series, one can specify vlans in FDB entries as well as to configure
> VLAN configuration on the bridge ports.
>

Stephen

This wad resent after you reopened iproute2.  Did you see it?  Do you 
have any further comments?

Thanks
-vlad

> Since v1:
>   - Rebased.
>   - Call rtnl_wilddump_req_filter from rtnl_wilddump_request.  Preserve always
>     setting the RTEXT_FILTER_VF filter.
>
> Vlad Yasevich (3):
>    bridge: Add vlan support to fdb entries
>    bridge: Add vlan configuration support
>    bridge: Update bridge man pages to include vlan command
>
>   bridge/Makefile      |    2 +-
>   bridge/br_common.h   |    1 +
>   bridge/bridge.c      |    3 +-
>   bridge/fdb.c         |   16 ++++-
>   bridge/vlan.c        |  220 ++++++++++++++++++++++++++++++++++++++++++++++++++
>   include/libnetlink.h |    2 +
>   lib/libnetlink.c     |    8 ++-
>   man/man8/bridge.8    |   73 ++++++++++++++++-
>   8 files changed, 320 insertions(+), 5 deletions(-)
>   create mode 100644 bridge/vlan.c
>
