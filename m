From: =?UTF-8?B?Q2hpYS1jaGkgWWVoICjokYnlrrbpvYop?= <chiachi@android.com>
Subject: Re: [PATCH] net: Keep interface binding when sending packets with
	ipi_ifindex = 0
Date: Tue, 4 Aug 2009 16:28:34 +0800
Message-ID: <6c039e090908040128l7bdaf45j3305e5e392562b85@mail.gmail.com>
References: <6c039e090907231439t1def08a4n10978733bee55bec@mail.gmail.com>
	 <20090727144402.513369f1.akpm@linux-foundation.org>
	 <1248912621.13447.12.camel@merlyn>
	 <20090803.212323.256579233.davem@davemloft.net>
	 <6c039e090908040036j38666152y2db1d4c55529eaff@mail.gmail.com>
	 <4A77E9FA.7030503@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, john.dykstra1@gmail.com,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Badalian Vyacheslav <slavon@bigtelecom.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.24]:9353 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755126AbZHDI2e convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 04:28:34 -0400
In-Reply-To: <4A77E9FA.7030503@bigtelecom.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 4, 2009 at 3:57 PM, Badalian Vyacheslav<slavon@bigtelecom.r=
u> wrote:
>
> Hello
> Sorry if its my mistake or i someone not understand :)
>
> if (ipc->oif && info->ipi_ifindex !=3D ipc->oif)
> =A0 =A0 =A0 =A0// if match: info->ipi_ifindex !=3D ipc->oif
> =A0 =A0 =A0 =A0return ...
> else
> =A0 =A0 =A0 =A0// else match: info->ipi_ifindex =3D=3D ipc->oif
> =A0 =A0 =A0 =A0// but you do
> =A0 =A0 =A0 =A0ipc->oif =3D info->ipi_ifindex;
> =A0 =A0 =A0 =A0// why if you else match allready check for it?
>
> Thanks

Hi Badalian,

Consider ipc->oif =3D 0 before the if-condition. :)

Chia-chi
