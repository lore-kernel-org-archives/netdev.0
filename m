From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2 0/3] net: dsa: voidify STP setter and FDB/VLAN
 add ops
Date: Wed, 6 Apr 2016 13:27:32 -0700
Message-ID: <CAGVrzcbyi7O+OWXF=CG0FMdZxoq4YWdDmA+7x3HiZf48weKLOQ@mail.gmail.com>
References: <1459958105-1090-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	kernel <kernel@savoirfairelinux.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>, Jiri Pirko <jiri@resnulli.us>,
	Scott Feldman <sfeldma@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:32931 "EHLO
	mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751649AbcDFU2M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 16:28:12 -0400
In-Reply-To: <1459958105-1090-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2016-04-06 8:55 GMT-07:00 Vivien Didelot <vivien.didelot@savoirfairelinux.com>:
> Neither the DSA layer nor the bridge code (see br_set_state) really care
> about eventual errors from STP state setters, so make it void.
>
> The DSA layer separates the prepare and commit phases of switchdev in
> two different functions. Logical errors must not happen in commit
> routines, so make them void.
>
> Changes v1 -> v2:
>   - rename port_stp_update to port_stp_state_set
>   - don't change code flow of bcm_sf2_sw_br_set_stp_state
>   - prefer netdev_err over netdev_warn
>
> Vivien Didelot (3):
>   net: dsa: make the STP state function return void
>   net: dsa: make the FDB add function return void
>   net: dsa: make the VLAN add function return void

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
