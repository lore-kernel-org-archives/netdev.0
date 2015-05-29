From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [RFC 1/3] net: dsa: add basic support for VLAN ndo
Date: Fri, 29 May 2015 15:15:23 -0700
Message-ID: <5568E4FB.6060309@roeck-us.net>
References: <556723FF.7030606@roeck-us.net>	<1432849035-8499-1-git-send-email-vivien.didelot@savoirfairelinux.com>	<1432849035-8499-2-git-send-email-vivien.didelot@savoirfairelinux.com>	<CAJ3xEMjYn+eeGHi5dyAhjHivid4UKUyGAi8pwVD4PBhKn1HTKQ@mail.gmail.com>	<2010513546.247697.1432913908579.JavaMail.zimbra@savoirfairelinux.com> <CAJ3xEMhAusqPj9m2a-wx7FDC2rE+WUk3UobE3+nS8qRV8bWTGg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	=?UTF-8?B?SsOpcm9tZSBPdWZlbGxh?=
	<jerome.oufella@savoirfairelinux.com>,
	Chris Healy <cphealy@gmail.com>, Jiri Pirko <jiri@resnulli.us>,
	Scott Feldman <sfeldma@gmail.com>
To: Or Gerlitz <gerlitz.or@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:34089 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756266AbbE2WP2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 18:15:28 -0400
In-Reply-To: <CAJ3xEMhAusqPj9m2a-wx7FDC2rE+WUk3UobE3+nS8qRV8bWTGg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/29/2015 08:51 AM, Or Gerlitz wrote:
> On Fri, May 29, 2015 at 6:38 PM, Vivien Didelot
> <vivien.didelot@savoirfairelinux.com> wrote:
>> Hi,
>>
>> ----- On May 29, 2015, at 11:24 AM, Or Gerlitz gerlitz.or@gmail.com wrote:
>>
>>> On Fri, May 29, 2015 at 12:37 AM, Vivien Didelot
>>> <vivien.didelot@savoirfairelinux.com> wrote:
>>>> @@ -854,7 +922,9 @@ int dsa_slave_create(struct dsa_switch *ds, struct device
>>>> *parent,
>>>>          if (slave_dev == NULL)
>>>>                  return -ENOMEM;
>>>>
>>>> -       slave_dev->features = master->vlan_features;
>>>> +       slave_dev->features = master->vlan_features |
>>>> +               NETIF_F_VLAN_FEATURES |
>>>> +               NETIF_F_HW_SWITCH_OFFLOAD;
>>>
>>> wait... didn't commit 7889cbee8357aaed85898d028829dfb4f75bae2c  remove
>>> NETIF_F_HW_SWITCH_OFFLOAD?
>>
>> Indeed, note that this RFC is based on v4.1-rc3. This will become unneeded I guess.
>
>
> You should rebase networking patches proposed for the next kernel
> against the net-next tree.
>
>> BTW, given the commit message, I didn't really understand why?
>
> M2, I thought it was unsuccessful commit message and made a comment to
> the maintainer, he didn't accept it.
>
Vivien,

sorry for asking for an early set of your patches. Obviously the idea was not
to create trouble for anyone :-(. I wasn't aware that netdev only accepts patches
which apply to the latest net-next, even if sent as RFC. My fault, I guess.

Maybe next time we can share patches in private first if we have a similar
situation ?

Thanks,
Guenter
