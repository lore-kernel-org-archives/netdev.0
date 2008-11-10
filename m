From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: 2.6.24.7 ipv6 send redirect
Date: Mon, 10 Nov 2008 10:17:56 +0200
Message-ID: <200811101017.56235.remi.denis-courmont@nokia.com>
References: <49149400.2060301@santabarbaralabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "ext Roman Chertov" <roman@santabarbaralabs.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.105.134]:36387 "EHLO
	mgw-mx09.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753928AbYKJISB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2008 03:18:01 -0500
In-Reply-To: <49149400.2060301@santabarbaralabs.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 07 November 2008 21:16:16 ext Roman Chertov, you wrote:
>     I need to disable IPv6 ICMP redirect messages.  In the
> /proc/sys/net/ipv4/conf/all/ there is a flag send_redirects which
> disables sending of the redirects in IPv4.  However, this option is n=
ot
> present in the /proc/sys/net/ipv6/conf/all/.  Did this option get mov=
ed
> to another location?  I would prefer to disable the redirects via a f=
lag
> and want to resort to changing the IPv6 forwarding code as the last
> measure.

In my understanding, disabling redirects on an IPv6 router is not allow=
ed by=20
the specification (see RFC4294 =A74.2).

--=20
R=E9mi Denis-Courmont
Maemo Software, Nokia Devices R&D
