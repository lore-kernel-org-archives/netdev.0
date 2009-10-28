From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: iproute uses too small of a receive buffer
Date: Wed, 28 Oct 2009 21:38:46 +0100
Message-ID: <4AE8ABD6.2010203@gmail.com>
References: <4AE77F64.3090302@candelatech.com> <20091027162434.6dc31b2d@nehalam> <4AE7F859.7020105@gmail.com> <4AE895E8.60308@trash.net> <4AE89927.9090405@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	NetDev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:56320 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755471AbZJ1Uiq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 16:38:46 -0400
In-Reply-To: <4AE89927.9090405@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear a =E9crit :

> Second:  Why bail on ENOBUFS at all?  I don't see how it helps the us=
er
> since they will probably just have to start it again, and will miss m=
ore
> messages than keeping going would have.
>=20
> And, even 1MB may not be enough for some scenarios.  So, probably bes=
t to
> let users over-ride the initial setting on cmd-line.  If not, then us=
e
> a large value to start with.
>=20

In this case, just dont call setsockopt() at all in "ip" and let system=
 use the
standard/default  value (/proc/sys/net/core/rmem_default) that an admin=
 can change
if he wants to handle one million devices :)

