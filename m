From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next 0/6] rocker: make master change handling nicer
Date: Wed, 26 Aug 2015 11:00:19 -0700
Message-ID: <CAE4R7bAR_vTePkfCHrrZQ35URFbdKCsLrKM-H0icFUP2rs0VCA@mail.gmail.com>
References: <1440606998-11072-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Ido Schimmel <idosch@mellanox.com>, eladr@mellanox.com,
	"simon.horman@netronome.com" <simon.horman@netronome.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f179.google.com ([209.85.214.179]:32830 "EHLO
	mail-ob0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752855AbbHZSAj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 14:00:39 -0400
Received: by obbhe7 with SMTP id he7so178620307obb.0
        for <netdev@vger.kernel.org>; Wed, 26 Aug 2015 11:00:38 -0700 (PDT)
In-Reply-To: <1440606998-11072-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 26, 2015 at 9:36 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> From: Jiri Pirko <jiri@mellanox.com>
>
> Jiri Pirko (6):
>   net: introduce change upper device notifier change info
>   net: add netif_is_bridge_master helper
>   net: add netif_is_ovs_master helper with IFF_OPENVSWITCH private flag
>   net: kill long time unused bonding private flags
>   rocker: use new helper to figure out master kind
>   rocker: use change upper info

Looks good Jiri, thanks for cleaning this up.  Only nit was about
conserving netdev->priv_flags.   Using rtnl_link_ops->kind to
determine netdev type scales better.
