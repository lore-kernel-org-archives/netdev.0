From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] CHOKe flow scheduler (iproute)
Date: Thu, 13 Jan 2011 22:01:49 +0100
Message-ID: <1294952509.3403.15.camel@edumazet-laptop>
References: <20110113092706.154748c2@s6510>  <20110113094847.565add51@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:63779 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752064Ab1AMVCP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jan 2011 16:02:15 -0500
Received: by wwa36 with SMTP id 36so2250637wwa.1
        for <netdev@vger.kernel.org>; Thu, 13 Jan 2011 13:01:52 -0800 (PST)
In-Reply-To: <20110113094847.565add51@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 13 janvier 2011 =C3=A0 09:48 -0800, Stephen Hemminger a =C3=A9=
crit :
> Preliminary interface for CHOKe scheduler in iproute
>=20
> +		return -1;
> +	fprintf(f, "limit %s min %s max %s ",
> +		sprint_size(qopt->limit, b1),
> +		sprint_size(qopt->qth_min, b2),
> +		sprint_size(qopt->qth_max, b3));
> +

sprint_size() adds 'b', not 'p' (packets)

fprintf(f, "limit %up min %up max %up ", qopt->limit, ...




