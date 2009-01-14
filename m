From: "Jorge Bastos" <mysql.jorge@decimal.pt>
Subject: Re: [BUG #12364] Re: HTB - very bad precision? HFSC works fine!  
     2.6.28
Date: Wed, 14 Jan 2009 19:37:00 -0000 (WET)
Message-ID: <2053.87.196.219.155.1231961820.squirrel@webmail.decimal.pt>
References: <1935.87.196.72.187.1231371721.squirrel@webmail.decimal.pt>
    <496AF0CE.7060406@trash.net>
    <2105.192.168.1.3.1231753688.squirrel@webmail.decimal.pt>
    <200901140353.49730.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Patrick McHardy" <kaber@trash.net>,
	"Jarek Poplawski" <jarkao2@gmail.com>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: "Denys Fedoryschenko" <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrly01.isp.novis.pt ([195.23.133.211]:43247 "EHLO
	mailrly01.isp.novis.pt" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752260AbZANThC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 14:37:02 -0500
In-Reply-To: <200901140353.49730.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Jorge - i guess your traffic is locally generated (on same PC where is
> shaper,
> this traffic generated), thats why shaping was not precise, with enabled
> GSO/TSO. I am right?
>
> My conclusion based on:
> eth0      Link encap:Ethernet  HWaddr 00:13:d4:68:c6:33
>           inet addr:195.23.114.76  Bcast:195.23.114.79
>  Mask:255.255.255.248
>
> and
> /sbin/tc filter add dev eth0 parent 1:0 protocol ip prio 100 u32 match ip
> src 195.23.114.76 match ip sport 80 0xffff classid 1
> :1280
>
>
>
> My traffic is "transit", means just passing router. I guess if it is
> correct,
> there must be statement about difference in locally generated traffic and
> transit traffic. TSO/GSO offloading i guess not done for "passing thru"
> traffic.
>

Denys,
Not correct, my traffic is transit as you say.
That is a public IP and that traffic is for public access only.

