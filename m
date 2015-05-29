From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [RFC 1/3] net: dsa: add basic support for VLAN ndo
Date: Fri, 29 May 2015 18:24:40 +0300
Message-ID: <CAJ3xEMjYn+eeGHi5dyAhjHivid4UKUyGAi8pwVD4PBhKn1HTKQ@mail.gmail.com>
References: <556723FF.7030606@roeck-us.net>
	<1432849035-8499-1-git-send-email-vivien.didelot@savoirfairelinux.com>
	<1432849035-8499-2-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Jerome Oufella <jerome.oufella@savoirfairelinux.com>,
	Chris Healy <cphealy@gmail.com>, Jiri Pirko <jiri@resnulli.us>,
	Scott Feldman <sfeldma@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f54.google.com ([209.85.218.54]:33611 "EHLO
	mail-oi0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752875AbbE2PYl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 11:24:41 -0400
Received: by oiww2 with SMTP id w2so58989078oiw.0
        for <netdev@vger.kernel.org>; Fri, 29 May 2015 08:24:40 -0700 (PDT)
In-Reply-To: <1432849035-8499-2-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 29, 2015 at 12:37 AM, Vivien Didelot
<vivien.didelot@savoirfairelinux.com> wrote:
> @@ -854,7 +922,9 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
>         if (slave_dev == NULL)
>                 return -ENOMEM;
>
> -       slave_dev->features = master->vlan_features;
> +       slave_dev->features = master->vlan_features |
> +               NETIF_F_VLAN_FEATURES |
> +               NETIF_F_HW_SWITCH_OFFLOAD;

wait... didn't commit 7889cbee8357aaed85898d028829dfb4f75bae2c  remove
NETIF_F_HW_SWITCH_OFFLOAD?
