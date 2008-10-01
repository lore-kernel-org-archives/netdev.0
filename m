From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: [PATCH 3/3] Phonet: declare headers
Date: Wed, 1 Oct 2008 10:54:52 +0300
Message-ID: <200810011054.52951.remi.denis-courmont@nokia.com>
References: <1222272700-28232-3-git-send-email-remi.denis-courmont@nokia.com> <20080930.025957.261573022.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "ext David Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:44485 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752993AbYJAHzY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 03:55:24 -0400
In-Reply-To: <20080930.025957.261573022.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 30 September 2008 12:59:57 ext David Miller, you wrote:
> From: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
> Date: Wed, 24 Sep 2008 19:11:40 +0300
>
> > Signed-off-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com=
>
>
> Applied.
>
> I took a look and noticed that if_phonet.h needs some top-level
> ifdef multiple inclusion protection.

Oops. Patch follows.

While we're on if_phonet.h, I also wonder what the "right" place for=20
phonet_header_ops is... Currently in phonet.ko, any network device driv=
er=20
link-depends on the socket stack :-( for two tiny little header_ops=20
callbacks. Is that OK? or should it go to core like the Ethernet ops, o=
r be=20
inline'd?

Regards,

--=20
R=E9mi Denis-Courmont
Maemo Software, Nokia Devices R&D
