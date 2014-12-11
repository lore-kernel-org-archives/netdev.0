From: vadim4j@gmail.com
Subject: Re: [PATCH iproute2] ip: Simplify executing ip cmd within namespace
Date: Thu, 11 Dec 2014 15:02:37 +0200
Message-ID: <20141211130237.GA867@angus-think.wlc.globallogic.com>
References: <1418252195-2612-1-git-send-email-vadim4j@gmail.com>
 <548978CD.80404@6wind.com>
 <20141211105733.GA17601@angus-think.wlc.globallogic.com>
 <54899309.7050109@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: vadim4j@gmail.com, netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:48166 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932200AbaLKNM3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 08:12:29 -0500
Received: by mail-lb0-f179.google.com with SMTP id z11so4056073lbi.38
        for <netdev@vger.kernel.org>; Thu, 11 Dec 2014 05:12:28 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <54899309.7050109@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 11, 2014 at 01:50:17PM +0100, Nicolas Dichtel wrote:
> Le 11/12/2014 11:57, vadim4j@gmail.com a =E9crit :
> >On Thu, Dec 11, 2014 at 11:58:21AM +0100, Nicolas Dichtel wrote:
> >>Le 10/12/2014 23:56, Vadim Kochan a =E9crit :
> >>>From: Vadim Kochan <vadim4j@gmail.com>
> >>>
> >>>Added new '-ns' option to simplify executing following cmd:
> >>>
> >>>     ip netns exec NETNS ip OPTIONS COMMAND OBJECT
> >>>
> >>>     to
> >>>
> >>>     ip -ns NETNS OPTIONS COMMAND OBJECT
> >>>
> >>>e.g.:
> >>>
> >>>     ip -ns vnet0 link add br0 type bridge
> >>>
> >>>Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
> >>>---
> >>>May be new option should have better name than '-ns' ?
> >>What about 'ip -netns' to be explicit like other options?
> >>user may still use 'ip -n' at the end.
> >>
> >>
> >>Regards,
> >>Nicolas
> >
> >May be left '-n' for some other future option, but use the following
> Options parsing in iproute2 will match -netns when typing -n because =
there
> is no other options that begin with a 'n' (I've done a quick look, ma=
ybe I've
> missed one).
> Like -d which matches -details, etc.
>=20
> >options: -net[ns] and -ns ? What do you think ?
> One option is enough. '-netns' is an explicit reference to 'ip netns'=
=2E
>=20
>=20
> Regards,
> Nicolas

OK, I agree.
I will re-work and resend v2.

Thanks,
