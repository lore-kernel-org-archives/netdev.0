From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 1/3] switchdev: fix: erasing too much of vlan
 obj when handling multiple vlan specs
Date: Wed, 21 Oct 2015 09:46:35 +0200
Message-ID: <20151021074635.GC2210@nanopsycho.orion>
References: <1445369799-2345-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, siva.mannem.lnx@gmail.com,
	vivien.didelot@savoirfairelinux.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:37733 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932088AbbJUHqi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 03:46:38 -0400
Received: by wicfv8 with SMTP id fv8so61856449wic.0
        for <netdev@vger.kernel.org>; Wed, 21 Oct 2015 00:46:36 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1445369799-2345-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Oct 20, 2015 at 09:36:37PM CEST, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>
>
>When adding vlans with multiple IFLA_BRIDGE_VLAN_INFO attrs set in AFSPEC,
>we would wipe the vlan obj struct after the first IFLA_BRIDGE_VLAN_INFO.
>Fix this by only clearing what's necessary on each IFLA_BRIDGE_VLAN_INFO
>iteration.
>
>Fixes: 9e8f4a54 ("switchdev: push object ID back to object structure")
>Signed-off-by: Scott Feldman <sfeldma@gmail.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
