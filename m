From: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [PATCH] bonding: document undocumented active_slave sysfs entry.
Date: Mon, 26 Dec 2011 23:51:11 +0100
Message-ID: <4EF8FA5F.8010609@gmail.com>
References: <1324901955-5816-1-git-send-email-nicolas.2p.debian@free.fr> <20213.1324933811@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@free.fr>, netdev@vger.kernel.org,
	Andy Gospodarek <andy@greyhouse.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:49263 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752552Ab1LZWu5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Dec 2011 17:50:57 -0500
Received: by wibhm6 with SMTP id hm6so4592957wib.19
        for <netdev@vger.kernel.org>; Mon, 26 Dec 2011 14:50:56 -0800 (PST)
In-Reply-To: <20213.1324933811@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 26/12/2011 22:10, Jay Vosburgh a =C3=A9crit :
> Nicolas de Peslo=C3=BCan 	<nicolas.2p.debian@free.fr>  wrote:
>
>> Signed-off-by: Nicolas de Peslo=C3=BCan<nicolas.2p.debian@free.fr>
>> cc: Jay Vosburgh<fubar@us.ibm.com>
>> cc: Andy Gospodarek<andy@greyhouse.net>
>>
>> ---
>> Documentation/networking/bonding.txt |   14 ++++++++++++++
>> 1 files changed, 14 insertions(+), 0 deletions(-)
>>
>> diff --git a/Documentation/networking/bonding.txt b/Documentation/ne=
tworking/bonding.txt
>> index 91df678..83b44c2 100644
>> --- a/Documentation/networking/bonding.txt
>> +++ b/Documentation/networking/bonding.txt
>> @@ -196,6 +196,20 @@ or, for backwards compatibility, the option val=
ue.  E.g.,
>>
>> 	The parameters are as follows:
>>
>> +active_slave
>> +
>> +	Specifies the active slave for modes that support it (active-backu=
p,
>> +	balance-alb and balance-tlb). The possible values are one of the
>> +	currently enslaved slaves. The selected slave must be up and the
>> +	underlying link must be up too.
>
> 	I would phrase this a bit differently, also including the empty
> string as a possible value:
>
> 	Specifies the new active slave for modes that support it
> 	(active-backup, balance-alb and balance-tlb).  Possible values
> 	are the name of any currently enslaved interface, or an empty
> 	string.  If a name is given, the slave must be up in order to be
> 	selected as the new active slave.  If an empty string is
> 	specified, the current active slave is cleared, and a new active
> 	slave is selected automatically.
>
>> +	Note that this is only available through the sysfs interface. No m=
odule
>> +	parameter by that name exists.
> =09
> 	"by this name" instead of "that".
>
>> +	The default value is empty (no active slave). It will automaticall=
y be
>> +	set every time an active slave is selected by normal bonding opera=
tion.
>> +	The current active slave can be read from this sysfs entry.
>
> 	I'd write this as:
>
> 	The normal value of this option is the name of the currently
> 	active slave, or the empty string if there is no active slave or
> 	the current mode does not use an active slave.
>
> 	With the above changes (or something pretty much equivalent) I'm
> good with this, and you can add a signed-off for me.


Thanks for the review. I will send V2 later.

	Nicolas.
