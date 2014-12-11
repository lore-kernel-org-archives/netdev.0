From: vadim4j@gmail.com
Subject: Re: [PATCH iproute2] ip: Simplify executing ip cmd within namespace
Date: Thu, 11 Dec 2014 12:57:33 +0200
Message-ID: <20141211105733.GA17601@angus-think.wlc.globallogic.com>
References: <1418252195-2612-1-git-send-email-vadim4j@gmail.com>
 <548978CD.80404@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Vadim Kochan <vadim4j@gmail.com>, netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:47693 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932508AbaLKLH0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 06:07:26 -0500
Received: by mail-la0-f53.google.com with SMTP id gm9so4124597lab.12
        for <netdev@vger.kernel.org>; Thu, 11 Dec 2014 03:07:25 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <548978CD.80404@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 11, 2014 at 11:58:21AM +0100, Nicolas Dichtel wrote:
> Le 10/12/2014 23:56, Vadim Kochan a =E9crit :
> >From: Vadim Kochan <vadim4j@gmail.com>
> >
> >Added new '-ns' option to simplify executing following cmd:
> >
> >     ip netns exec NETNS ip OPTIONS COMMAND OBJECT
> >
> >     to
> >
> >     ip -ns NETNS OPTIONS COMMAND OBJECT
> >
> >e.g.:
> >
> >     ip -ns vnet0 link add br0 type bridge
> >
> >Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
> >---
> >May be new option should have better name than '-ns' ?
> What about 'ip -netns' to be explicit like other options?
> user may still use 'ip -n' at the end.
>=20
>=20
> Regards,
> Nicolas

May be left '-n' for some other future option, but use the following
options: -net[ns] and -ns ? What do you think ?

Thanks,
