From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next v2 0/4] net: dsa: Preparatory patches for pdata
Date: Wed, 06 Jul 2016 22:00:30 -0400
Message-ID: <87vb0imcld.fsf@ketchup.mtl.sfl>
References: <1467756433-25062-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, andrew@lunn.ch,
	Florian Fainelli <f.fainelli@gmail.com>
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:58500 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751504AbcGGCAe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2016 22:00:34 -0400
In-Reply-To: <1467756433-25062-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Florian Fainelli <f.fainelli@gmail.com> writes:

> Hi all,
>
> This is a resend of the patches that just clean up and prepare net/dsa/dsa2.c
> to support platform data in the future.
>
> Florian Fainelli (4):
>   net: dsa: Pass device pointer to dsa_register_switch
>   net: dsa: Make most functions take a dsa_port argument
>   net: dsa: Suffix function manipulating device_node with _dn
>   net: dsa: Move ports assignment closer to error checking
>
>  drivers/net/dsa/b53/b53_common.c |  2 +-
>  drivers/net/dsa/mv88e6xxx/chip.c |  7 ++--
>  include/net/dsa.h                |  2 +-
>  net/dsa/dsa.c                    | 14 ++++---
>  net/dsa/dsa2.c                   | 87 ++++++++++++++++++++++------------------
>  net/dsa/dsa_priv.h               |  4 +-
>  6 files changed, 62 insertions(+), 54 deletions(-)

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Thanks,

        Vivien
