From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: use hardware buffer pool to allocate skb
Date: Fri, 17 Oct 2014 07:05:09 -0700
Message-ID: <1413554709.24953.5.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1413343571-33231-1-git-send-email-Jiafei.Pan@freescale.com>
	 <20141015.002514.384962932982389732.davem@davemloft.net>
	 <c02005b9d8794d14bc2149f468ab571c@BY2PR03MB524.namprd03.prod.outlook.com>
	 <1413364533.12304.44.camel@edumazet-glaptop2.roam.corp.google.com>
	 <524626e093684abeba65839d26e94262@BLUPR03MB517.namprd03.prod.outlook.com>
	 <1413432912.28798.7.camel@edumazet-glaptop2.roam.corp.google.com>
	 <aeef795129504782ae1e9f91467d243e@BLUPR03MB517.namprd03.prod.outlook.com>
	 <543FE413.6030406@redhat.com>
	 <92e45ba6015c4c48b21baeade3f9c929@BLUPR03MB517.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Duyck <alexander.h.duyck@redhat.com>,
	David Miller <davem@davemloft.net>,
	"jkosina@suse.cz" <jkosina@suse.cz>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"LeoLi@freescale.com" <LeoLi@freescale.com>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>
To: "Jiafei.Pan@freescale.com" <Jiafei.Pan@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:47188 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751408AbaJQOFL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2014 10:05:11 -0400
In-Reply-To: <92e45ba6015c4c48b21baeade3f9c929@BLUPR03MB517.namprd03.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-10-17 at 02:35 +0000, Jiafei.Pan@freescale.com wrote:

> [Pan Jiafei] Hi, Alex, thanks for your comments. I don=E2=80=99t conf=
irm that
> you have catch my concerns. For example, I want to add igb net card=20
> into my bridge, and want to igb net driver allocate skb by using
> my specified memory address, but I don=E2=80=99t want to modify igb n=
et driver
> directly, how to do this in my bridge drivers?

This is exactly our point : We do not want to modify all drivers so tha=
t
your bridge is happy with them.

You'll have to make your bridge using standard infra instead.

IGB has no way to know in advance that a particular frame should
eventually reach your bridge anyway.
