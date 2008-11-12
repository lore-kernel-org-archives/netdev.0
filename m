From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: Why does IPV6 link local address advertised as /64?
Date: Wed, 12 Nov 2008 09:44:19 +0200
Message-ID: <200811120944.20079.remi.denis-courmont@nokia.com>
References: <20081111204906.081d9d57@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "ext Stephen Hemminger" <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:18849 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751144AbYKLHol convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 02:44:41 -0500
In-Reply-To: <20081111204906.081d9d57@extreme>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 12 November 2008 06:49:06 ext Stephen Hemminger, you wrote=
:
> It seems to make more sense to have only the actual host (ie /128)
> on the link-local address or is there some other purpose to
> using a /64?

=46or the same reason that IPv4 link-local (169.254/16) addresses are /=
16 rather=20
than a /32. There are LINK-local addresses, not HOST-local addresses - =
you=20
must be able to talk to other nodes on the link with them.

--=20
R=E9mi Denis-Courmont
Maemo Software, Nokia Devices R&D
