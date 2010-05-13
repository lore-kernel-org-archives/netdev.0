From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: Re: [PATCH net-next] drivers/net: Remove unnecessary returns from
	void function()s
Date: Thu, 13 May 2010 11:37:40 -0700
Message-ID: <AANLkTilvufsaxS6fMIvyobnTIPmWdMdNJxsxuoKdVA_X@mail.gmail.com>
References: <1273606224.20514.295.camel@Joe-Laptop.home>
	 <1273769886.21514.72.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:35279 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759207Ab0EMShl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 May 2010 14:37:41 -0400
Received: by fxm6 with SMTP id 6so696460fxm.19
        for <netdev@vger.kernel.org>; Thu, 13 May 2010 11:37:40 -0700 (PDT)
In-Reply-To: <1273769886.21514.72.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 13, 2010 at 9:58 AM, Joe Perches <joe@perches.com> wrote:
> On Tue, 2010-05-11 at 12:30 -0700, Joe Perches wrote:
>> diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bon=
ding.h
>> index 2aa3367..02497bc 100644
>> --- a/drivers/net/bonding/bonding.h
>> +++ b/drivers/net/bonding/bonding.h
>> @@ -368,15 +368,12 @@ void bond_unregister_ipv6_notifier(void);
>> =C2=A0#else
>> =C2=A0static inline void bond_send_unsolicited_na(struct bonding *bo=
nd)
>> =C2=A0{
>> - =C2=A0 =C2=A0 return;
>> =C2=A0}
>> =C2=A0static inline void bond_register_ipv6_notifier(void)
>> =C2=A0{
>> - =C2=A0 =C2=A0 return;
>> =C2=A0}
>> =C2=A0static inline void bond_unregister_ipv6_notifier(void)
>> =C2=A0{
>> - =C2=A0 =C2=A0 return;
>> =C2=A0}
>> =C2=A0#endif
>
> fyi: Patrick McHardy prefers null statement void functions to
> keep the return.
>
> There are some more removals of return like this in the patch.
> If a new patch should be generated, do tell.
>

If you're looking to save a few more lines, many places do the followin=
g:

static inline void bond_unregister_ipv6_notifier(void) {}

Cheers,

Harvey
