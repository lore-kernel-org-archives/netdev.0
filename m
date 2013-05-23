From: =?ISO-8859-1?Q?Emilio_L=F3pez?= <emilio@elopez.com.ar>
Subject: Re: [PATCH 3/3] net: ethernet: sun: drop unused variable
Date: Thu, 23 May 2013 09:54:23 -0300
Message-ID: <519E117F.9040707@elopez.com.ar>
References: <20130522.122624.266893118412034519.davem@davemloft.net> <1369267057-9371-1-git-send-email-emilio@elopez.com.ar> <1369267057-9371-3-git-send-email-emilio@elopez.com.ar> <20130522.234318.1664796969540142910.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zetta.elopez.com.ar ([199.30.59.35]:37518 "EHLO
	zetta.elopez.com.ar" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758432Ab3EWMyd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 May 2013 08:54:33 -0400
In-Reply-To: <20130522.234318.1664796969540142910.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

El 23/05/13 03:43, David Miller escribi=F3:
> From: Emilio L=F3pez <emilio@elopez.com.ar>
> Date: Wed, 22 May 2013 20:57:37 -0300
>=20
>> Commit bfd428d ("net: ethernet: sun: initialize variables directly")
>> dropped the only loop that was using i but did not remove the actual
>> variable, therefore causing a warning when building. This patch drop=
s
>> the now redundant line.
>>
>> Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
>> Signed-off-by: Emilio L=F3pez <emilio@elopez.com.ar>
>=20
> Applied.

I see that you applied the series in net instead of net-next; the
previous patches were in net-next only. This will cause build breakage
in net because the loop is still there.

Regards,

Emilio
