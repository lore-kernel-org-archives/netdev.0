From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net] rtnl: don't send rtnl msg for unregistered iface
Date: Mon, 11 May 2015 18:04:01 +0200
Message-ID: <5550D2F1.5030100@6wind.com>
References: <1431354346-4476-1-git-send-email-nicolas.dichtel@6wind.com> <20150511153741.GB2222@nanopsycho.mtl.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, j.vosburgh@gmail.com,
	vfalico@gmail.com, gospo@cumulusnetworks.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:33810 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751200AbbEKQEE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 12:04:04 -0400
Received: by wgic8 with SMTP id c8so106415550wgi.1
        for <netdev@vger.kernel.org>; Mon, 11 May 2015 09:04:03 -0700 (PDT)
In-Reply-To: <20150511153741.GB2222@nanopsycho.mtl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 11/05/2015 17:37, Jiri Pirko a =E9crit :
[snip]
>
> I don't think this is the correct way to fix this.
>
> How ifindex can be 0 here? Ifindex is set in register_netdevice and
> looking at bond_create, I don't see any call to __bond_opt_set before
> that. But since it apparently is, the ordering should be changed so
> register_netdevice is called first.
bond_newlink =3D> bond_changelink =3D> __bond_opt_set
and then back to bond_newlink =3D> register_netdevice


Regards,
Nicolas
