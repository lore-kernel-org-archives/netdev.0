From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: segfault after VLAN change
Date: Wed, 02 Jul 2014 12:22:27 +0200
Message-ID: <87mwcs12n0.fsf@nemi.mork.no>
References: <42408b4f154d434d9838b83ae2dc15db@BL2PR03MB545.namprd03.prod.outlook.com>
	<87simk1bhu.fsf@nemi.mork.no>
	<1404289423.23797.1.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Madalin-Cristian Bucur <madalin.bucur@freescale.com>,
	Li RongQing <roy.qing.li@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:37963 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750796AbaGBKWt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 06:22:49 -0400
In-Reply-To: <1404289423.23797.1.camel@edumazet-glaptop2.roam.corp.google.com>
	(Eric Dumazet's message of "Wed, 02 Jul 2014 01:23:43 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:

> Sure a 'revert' helps, but the real bug should be fixed.
>
> The freeing of the percpu structure should happen from
> dev->destructor(), not from ndo_uninit

That makes sense.  Thanks for fixing this.


Bj=C3=B8rn
