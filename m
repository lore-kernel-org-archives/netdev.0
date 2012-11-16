From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next 1/4] ipip: allow to deactivate the creation of
 fb dev
Date: Fri, 16 Nov 2012 17:46:11 +0100
Message-ID: <50A66DD3.20807@6wind.com>
References: <1353082456-21234-1-git-send-email-nicolas.dichtel@6wind.com> <1353082456-21234-2-git-send-email-nicolas.dichtel@6wind.com> <20121116082926.1c6cccd2@nehalam.linuxnetplumber.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:64192 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751564Ab2KPQqQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 11:46:16 -0500
Received: by mail-ee0-f46.google.com with SMTP id b15so1733755eek.19
        for <netdev@vger.kernel.org>; Fri, 16 Nov 2012 08:46:15 -0800 (PST)
In-Reply-To: <20121116082926.1c6cccd2@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 16/11/2012 17:29, Stephen Hemminger a =E9crit :
> On Fri, 16 Nov 2012 17:14:13 +0100
> Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:
>
>> Now that tunnels can be configured via rtnetlink, this device is not=
 mandatory.
>> The default is conservative.
>>
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>
>
> Although I am in favor of reducing clutter, and we even have to put i=
n special case
> code to ignore these stub devices in the Vyatta scripts. Module param=
eters are bit of a nuisance to deal with, but maybe
> the only way for this kind of thing and keep the required ABI.
>
> Not sure if I can fully endorse this. The device may still have uses.
> It is still useful for capturing "none of the above" packets
If you need to capture these packets, you can still create a tunnel wit=
h local=20
any and remote any, even if the fb_device has not been created.

> and is used to auto-load module via module aliases.
Right, but if user uses netlink, the problem exists without these patch=
es too.

By default, the fb device is created, so there is no change if you don'=
t set=20
explicitly setup_fb to 0.
