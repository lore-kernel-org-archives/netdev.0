From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net 2/2] net: Verify permission to link_net in newlink
Date: Fri, 27 Feb 2015 10:03:37 +0100
Message-ID: <54F032E9.6020908@6wind.com>
References: <CAOYZPENnpPP-N-ST3xYE7vcCFhbNd-FMKj9OvBebYSMu42OdaQ@mail.gmail.com>	<54EDF7BB.2060809@6wind.com> <871tldstju.fsf_-_@x220.int.ebiederm.org>	<54EEDF9C.20302@6wind.com> <87wq34okb9.fsf@x220.int.ebiederm.org>	<54EF3338.8000409@6wind.com> <87egpcmi3v.fsf_-_@x220.int.ebiederm.org> <877fv4mi20.fsf_-_@x220.int.ebiederm.org>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eugene Yakubovich <eugene.yakubovich@coreos.com>,
	netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:42880 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754583AbbB0JDk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 04:03:40 -0500
Received: by wghl2 with SMTP id l2so18576201wgh.9
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2015 01:03:39 -0800 (PST)
In-Reply-To: <877fv4mi20.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 26/02/2015 23:20, Eric W. Biederman a =C3=A9crit :
>
> When applicable verify that the caller has permisson to the underlyin=
g
> network namespace for a newly created network device.
>
> Similary checks exist for the network namespace a network device will
> be created in.
>
> Fixes: v4.0-rc1
=46ixes: 317f4810e45e ("rtnl: allow to create device with IFLA_LINK_NET=
NSID set")
Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
