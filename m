From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [RFC 1/3] net: dsa: add basic support for VLAN ndo
Date: Fri, 29 May 2015 11:38:28 -0400 (EDT)
Message-ID: <2010513546.247697.1432913908579.JavaMail.zimbra@savoirfairelinux.com>
References: <556723FF.7030606@roeck-us.net> <1432849035-8499-1-git-send-email-vivien.didelot@savoirfairelinux.com> <1432849035-8499-2-git-send-email-vivien.didelot@savoirfairelinux.com> <CAJ3xEMjYn+eeGHi5dyAhjHivid4UKUyGAi8pwVD4PBhKn1HTKQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	=?utf-8?Q?J=C3=A9rome?= Oufella
	<jerome.oufella@savoirfairelinux.com>,
	Chris Healy <cphealy@gmail.com>, Jiri Pirko <jiri@resnulli.us>,
	Scott Feldman <sfeldma@gmail.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([209.172.62.77]:56968 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756393AbbE2Pic (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 11:38:32 -0400
In-Reply-To: <CAJ3xEMjYn+eeGHi5dyAhjHivid4UKUyGAi8pwVD4PBhKn1HTKQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

----- On May 29, 2015, at 11:24 AM, Or Gerlitz gerlitz.or@gmail.com wrote:

> On Fri, May 29, 2015 at 12:37 AM, Vivien Didelot
> <vivien.didelot@savoirfairelinux.com> wrote:
>> @@ -854,7 +922,9 @@ int dsa_slave_create(struct dsa_switch *ds, struct device
>> *parent,
>>         if (slave_dev == NULL)
>>                 return -ENOMEM;
>>
>> -       slave_dev->features = master->vlan_features;
>> +       slave_dev->features = master->vlan_features |
>> +               NETIF_F_VLAN_FEATURES |
>> +               NETIF_F_HW_SWITCH_OFFLOAD;
> 
> wait... didn't commit 7889cbee8357aaed85898d028829dfb4f75bae2c  remove
> NETIF_F_HW_SWITCH_OFFLOAD?

Indeed, note that this RFC is based on v4.1-rc3. This will become unneeded I guess.

BTW, given the commit message, I didn't really understand why?

Thanks,
-v
