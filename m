From: =?UTF-8?Q?Sjur_Br=C3=A6ndeland?= <sjurbren@gmail.com>
Subject: Re: [RFC 2/3] if_ether.h: Add IEEE 802.1 Local Experimental Ethertype 1.
Date: Mon, 5 Dec 2011 15:33:50 +0100
Message-ID: <CAJK669ZhM_KSOd0MS7jTVvJ16KqNzPCj-Ns1ytN5NPg5PxgoOQ@mail.gmail.com>
References: <1322685846-7790-1-git-send-email-sjur.brandeland@stericsson.com>
	<1322685846-7790-3-git-send-email-sjur.brandeland@stericsson.com>
	<5636a5efd90c56b538569ab019d7be4c@chewa.net>
	<CAJK669bK8kBXfc=j1q5NWEDCgSZwO0O=LsZ8z5GzB0S07gwBEQ@mail.gmail.com>
	<ff290c739be323dec89d19ed905feb94@chewa.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Alexey Orishko <alexey.orishko@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: =?UTF-8?Q?R=C3=A9mi_Denis=2DCourmont?= <remi@remlab.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:36383 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932239Ab1LEOdv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2011 09:33:51 -0500
Received: by qadb40 with SMTP id b40so1146374qad.19
        for <netdev@vger.kernel.org>; Mon, 05 Dec 2011 06:33:51 -0800 (PST)
In-Reply-To: <ff290c739be323dec89d19ed905feb94@chewa.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi R=C3=A9mi,
> It's even weirder then. If you have control over both ends and the NC=
M 1.0
> interface is not adequate, then you really should use your own CDC cl=
ass
> for the purpose.

The reason we use NCM is performance: CDC normally gives less than 100M=
bps,
while NCM can give you up to 200Mbps.

Regards,
Sjur
