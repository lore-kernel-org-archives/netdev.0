From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH] net: r8169: convert to hw_features
Date: Fri, 8 Apr 2011 14:44:06 +0200
Message-ID: <20110408124406.GA22478@rere.qmqm.pl>
References: <20110408123847.64FF813A64@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Francois Romieu <romieu@fr.zoreil.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:57663 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756133Ab1DHMoH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Apr 2011 08:44:07 -0400
Content-Disposition: inline
In-Reply-To: <20110408123847.64FF813A64@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 08, 2011 at 02:38:46PM +0200, Micha=B3 Miros=B3aw wrote:
> This enables SG+IP_CSUM+TSO by default (there were no comments sugges=
ting
> leaving them out was intentional).
>=20
> This also fixes confusion around vlan_features in rtl8169_vlan_mode()=
=2E

BTW, I noticed that TSO will break for MTU > 4095+(TCP+IP header len).
This needs handing in ndo_fix_features callback like other MTU-limited =
TSO
engines.

Best Regards,
Micha=B3 Miros=B3aw
