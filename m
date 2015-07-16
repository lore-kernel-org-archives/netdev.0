From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v2 0/5] switchdev: avoid duplicate packet
 forwarding
Date: Thu, 16 Jul 2015 10:23:46 +0200
Message-ID: <20150716082346.GH2145@nanopsycho.orion>
References: <1437033897-8050-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	simon.horman@netronome.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:33398 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754447AbbGPIXt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2015 04:23:49 -0400
Received: by widic2 with SMTP id ic2so8629194wid.0
        for <netdev@vger.kernel.org>; Thu, 16 Jul 2015 01:23:48 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1437033897-8050-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


......
>
>Scott Feldman (5):
>  net: don't reforward packets already forwarded by offload device
>  net: add phys ID compare helper to test if two IDs are the same
>  switchdev: add offload_fwd_mark generator helper
>  rocker: add offload_fwd_mark support
>  switchdev: update documentation for offload_fwd_mark
>
> Documentation/networking/switchdev.txt |   14 +++-
> drivers/net/ethernet/rocker/rocker.c   |   11 ++++
> drivers/net/ethernet/rocker/rocker.h   |    1 +
> include/linux/netdevice.h              |   13 ++++
> include/linux/skbuff.h                 |   11 +++-
> include/net/switchdev.h                |    9 +++
> net/core/dev.c                         |   10 +++
> net/switchdev/switchdev.c              |  111 ++++++++++++++++++++++++++++++--
> 8 files changed, 171 insertions(+), 9 deletions(-)
>
>-- 
>1.7.10.4

Thanks for taking care of this Scott!
