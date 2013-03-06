From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCHv2 iproute2 0/3] Bridge VLAN support
Date: Wed, 6 Mar 2013 11:06:29 -0800
Message-ID: <20130306110629.2daf6563@nehalam.linuxnetplumber.net>
References: <1362081846-25268-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:47663 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752638Ab3CFTGe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Mar 2013 14:06:34 -0500
Received: by mail-pb0-f52.google.com with SMTP id ma3so6413270pbc.11
        for <netdev@vger.kernel.org>; Wed, 06 Mar 2013 11:06:33 -0800 (PST)
In-Reply-To: <1362081846-25268-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 28 Feb 2013 15:04:03 -0500
Vlad Yasevich <vyasevic@redhat.com> wrote:

> This series adds VLAN configuration to the bridge command.  With this
> series, one can specify vlans in FDB entries as well as to configure
> VLAN configuration on the bridge ports.
> 
> Since v1:
>  - Rebased.
>  - Call rtnl_wilddump_req_filter from rtnl_wilddump_request.  Preserve always
>    setting the RTEXT_FILTER_VF filter.
> 
> Vlad Yasevich (3):
>   bridge: Add vlan support to fdb entries
>   bridge: Add vlan configuration support
>   bridge: Update bridge man pages to include vlan command
> 
>  bridge/Makefile      |    2 +-
>  bridge/br_common.h   |    1 +
>  bridge/bridge.c      |    3 +-
>  bridge/fdb.c         |   16 ++++-
>  bridge/vlan.c        |  220 ++++++++++++++++++++++++++++++++++++++++++++++++++
>  include/libnetlink.h |    2 +
>  lib/libnetlink.c     |    8 ++-
>  man/man8/bridge.8    |   73 ++++++++++++++++-
>  8 files changed, 320 insertions(+), 5 deletions(-)
>  create mode 100644 bridge/vlan.c
> 

Applied now in HEAD of iproute2 git
