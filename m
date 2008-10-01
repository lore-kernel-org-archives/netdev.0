From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] Phonet: declare headers
Date: Wed, 01 Oct 2008 01:32:13 -0700 (PDT)
Message-ID: <20081001.013213.193713776.davem@davemloft.net>
References: <1222272700-28232-3-git-send-email-remi.denis-courmont@nokia.com>
	<20080930.025957.261573022.davem@davemloft.net>
	<200810011054.52951.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: remi.denis-courmont@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44504
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752392AbYJAIcY convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Oct 2008 04:32:24 -0400
In-Reply-To: <200810011054.52951.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "R=E9mi Denis-Courmont" <remi.denis-courmont@nokia.com>
Date: Wed, 1 Oct 2008 10:54:52 +0300

> While we're on if_phonet.h, I also wonder what the "right" place for=20
> phonet_header_ops is... Currently in phonet.ko, any network device dr=
iver=20
> link-depends on the socket stack :-( for two tiny little header_ops=20
> callbacks. Is that OK? or should it go to core like the Ethernet ops,=
 or be=20
> inline'd?

The drivers are kind of useless without the socket layer
so it doesn't seem so awful to have this dependency.
