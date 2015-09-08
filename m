From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH net-next 1/3] net: switchdev: extract
 switchdev_obj_vlan
Date: Tue, 8 Sep 2015 22:58:41 +0200
Message-ID: <20150908205841.GF29184@lunn.ch>
References: <1441745275-13200-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1441745275-13200-2-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@resnulli.us>,
	Scott Feldman <sfeldma@gmail.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	kernel@savoirfairelinux.com
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:33542 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751489AbbIHVG3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Sep 2015 17:06:29 -0400
Content-Disposition: inline
In-Reply-To: <1441745275-13200-2-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +/* SWITCHDEV_OBJ_PORT_VLAN */
> +struct switchdev_obj_vlan {
> +	struct switchdev_obj obj;	/* must be first */
> +	u16 flags;
> +	u16 vid_begin;
> +	u16 vid_end;
> +};

I know you give a few examples for where this is done in network code,
but i think container_of() is used much more. You can then place the
struct switchdev_obj anywhere in the structure, and it will work.

#define to_switchdev_obj_vlan(o) container_of(o, struct switchdev_obj_vlan, obj)

	Andrew
