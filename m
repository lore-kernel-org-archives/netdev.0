From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: Kernel panic eth2 mirred redirect to ifb0
Date: Mon, 20 Dec 2010 22:05:12 +0800
Message-ID: <AANLkTi=eqCWpFpHQ86_yO544p5G6J6P2os7rCR9FBtUd@mail.gmail.com>
References: <AANLkTi=R_ZsYgsYd7EkxHRFTKjtLyLQAOYay2nBV=0bK@mail.gmail.com>
 <1292836885.2800.4.camel@edumazet-laptop> <20101220103226.GB7977@ff.dom.local>
 <1292841671.2800.11.camel@edumazet-laptop> <20101220111141.GC7977@ff.dom.local>
 <20101220115855.GD7977@ff.dom.local> <4D0F471D.8030607@itcare.pl>
 <20101220122256.GA9325@ff.dom.local> <1292849150.2800.25.camel@edumazet-laptop>
 <1292849687.2800.27.camel@edumazet-laptop> <20101220130247.GB9325@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	=?ISO-8859-2?Q?Pawe=B3_Staszewski?= <pstaszewski@itcare.pl>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:42703 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757818Ab0LTOFe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Dec 2010 09:05:34 -0500
Received: by fxm18 with SMTP id 18so3052278fxm.2
        for <netdev@vger.kernel.org>; Mon, 20 Dec 2010 06:05:33 -0800 (PST)
In-Reply-To: <20101220130247.GB9325@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2010/12/20 Jarek Poplawski <jarkao2@gmail.com>:
>
> IMHO it should, (probably even more, like loopback) but we should
> consider mirred can xmit to other than ifb too.
>

I also think so. And when making ifb a multiqueue NIC, I tried to add
these dev features to ifb. :)

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
