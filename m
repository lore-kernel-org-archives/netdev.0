From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH next 5/6] bonding: Allow userspace to set macaddr on bonding-dev
Date: Sat, 7 Feb 2015 19:32:57 -0800
Message-ID: <CAF2d9jgi11=FHEZVkdOZ3EKBAMa7pL6NLroy=Dtr-+68B8Tdcg@mail.gmail.com>
References: <1423270316-9311-1-git-send-email-maheshb@google.com> <20150207142652.708bd66e@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:43305 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751797AbbBHDdT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2015 22:33:19 -0500
Received: by mail-ob0-f175.google.com with SMTP id va2so19917810obc.6
        for <netdev@vger.kernel.org>; Sat, 07 Feb 2015 19:33:18 -0800 (PST)
In-Reply-To: <20150207142652.708bd66e@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 7, 2015 at 2:26 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Fri,  6 Feb 2015 16:51:56 -0800
> Mahesh Bandewar <maheshb@google.com> wrote:
>
>> @@ -396,6 +398,13 @@ static const struct bond_option bond_opts[BOND_OPT_LAST] = {
>>               .values = bond_ad_actor_sysprio_tbl,
>>               .set = bond_option_ad_actor_sysprio_set,
>>       },
>> +     [BOND_OPT_AD_ACTOR_SYS_MACADDR] = {
>> +             .id = BOND_OPT_AD_ACTOR_SYS_MACADDR,
>> +             .name = "ad_actor_system_mac_address",
>> +             .unsuppmodes = BOND_MODE_ALL_EX(BIT(BOND_MODE_8023AD)),
>> +             .flags = BOND_OPTFLAG_RAWVAL | BOND_OPTFLAG_IFDOWN,
>> +             .set = bond_option_ad_actor_sys_macaddr_set,
>> +     },
>>  };
>
> I would consider the module command line options deprecated
> at this point. Why add more?

These are not the module parameters.
