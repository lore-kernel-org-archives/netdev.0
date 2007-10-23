From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH RESEND] ip_gre: sendto/recvfrom NBMA address
Date: Tue, 23 Oct 2007 18:10:20 +0200
Message-ID: <471E1CEC.5020005@trash.net>
References: <471E05BD.7040407@iki.fi> <471E0638.9040405@trash.net> <471E19E5.5040509@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru
To: =?ISO-8859-15?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49563 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751564AbXJWQKY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2007 12:10:24 -0400
In-Reply-To: <471E19E5.5040509@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Timo Ter=E4s wrote:
> When GRE tunnel is in NBMA mode, this patch allows an application to =
use
> a PF_PACKET socket to:
> - send a packet to specific NBMA address with sendto()
> - use recvfrom() to receive packet and check which NBMA address it=20
> came from
>
> This is required to implement properly NHRP over GRE tunnel.
>
> Signed-off-by: Timo Teras <timo.teras@iki.fi>
>
> ---
> Patrick McHardy wrote:
>> Your mailer mangled tabs, it won't apply like this. Try sending to
>> yourself for testing, then repost when it works properly.
>
> Tabs were ok, I think. But somehow it seems that cut'n'paste from my
> default editor loses the space from context lines. It should be good =
now.

Might have been a problem on my side, I just updated my mailer
and it still displays tabs broken, but the actual patch seems
fine. Sorry for the noise ...


