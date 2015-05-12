From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net] rtnl: don't send rtnl msg for unregistered iface
Date: Tue, 12 May 2015 10:43:16 +0200
Message-ID: <5551BD24.4070600@6wind.com>
References: <1431354346-4476-1-git-send-email-nicolas.dichtel@6wind.com> <20150511153741.GB2222@nanopsycho.mtl.com> <5550D2F1.5030100@6wind.com> <5550D584.9010703@6wind.com> <20150511175355.GA3130@nanopsycho>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, j.vosburgh@gmail.com,
	vfalico@gmail.com, gospo@cumulusnetworks.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:35613 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932227AbbELInU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 04:43:20 -0400
Received: by widdi4 with SMTP id di4so141888928wid.0
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 01:43:18 -0700 (PDT)
In-Reply-To: <20150511175355.GA3130@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 11/05/2015 19:53, Jiri Pirko a =E9crit :
[snip]
> Or, change __bond_opt_set to call call_netdevice_notifiers only in ca=
se
> dev->reg_state =3D=3D NETREG_REGISTERED? Looking at the other places =
this
Why not. It will fix this bug, but I tend to put something more general=
 in
rtnetlink to avoid such bug in the future.
