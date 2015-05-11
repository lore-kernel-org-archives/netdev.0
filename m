From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net] rtnl: don't send rtnl msg for unregistered iface
Date: Mon, 11 May 2015 18:15:00 +0200
Message-ID: <5550D584.9010703@6wind.com>
References: <1431354346-4476-1-git-send-email-nicolas.dichtel@6wind.com> <20150511153741.GB2222@nanopsycho.mtl.com> <5550D2F1.5030100@6wind.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, j.vosburgh@gmail.com,
	vfalico@gmail.com, gospo@cumulusnetworks.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:33307 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752690AbbEKQPD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 12:15:03 -0400
Received: by wgin8 with SMTP id n8so133360215wgi.0
        for <netdev@vger.kernel.org>; Mon, 11 May 2015 09:15:02 -0700 (PDT)
In-Reply-To: <5550D2F1.5030100@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 11/05/2015 18:04, Nicolas Dichtel a =E9crit :
> Le 11/05/2015 17:37, Jiri Pirko a =E9crit :
> [snip]
>>
>> I don't think this is the correct way to fix this.
>>
>> How ifindex can be 0 here? Ifindex is set in register_netdevice and
>> looking at bond_create, I don't see any call to __bond_opt_set befor=
e
>> that. But since it apparently is, the ordering should be changed so
>> register_netdevice is called first.
I also don't see why we would prevent to register a bonding interface d=
irectly
with the right mode.

> bond_newlink =3D> bond_changelink =3D> __bond_opt_set
> and then back to bond_newlink =3D> register_netdevice
>
>
> Regards,
> Nicolas
