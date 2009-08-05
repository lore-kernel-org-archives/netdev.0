From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: [PATCH 1/2] net: implement a SO_PROTOCOL getsockoption
Date: Wed, 5 Aug 2009 09:35:03 +0300
Message-ID: <200908050935.03272.remi.denis-courmont@nokia.com>
References: <1249406909-24161-1-git-send-email-jengelh@medozas.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: ext Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.105.134]:32709 "EHLO
	mgw-mx09.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755538AbZHEGgL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2009 02:36:11 -0400
In-Reply-To: <1249406909-24161-1-git-send-email-jengelh@medozas.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 04 August 2009 20:28:28 ext Jan Engelhardt wrote:
> Similar to SO_TYPE returning the socket type, SO_PROTOCOL allows to
> retrieve the protocol used with a given socket.

You can easily infer the protocol family from the address family from=20
getsockname().

As for the protocol, at least for raw IP sockets, you can get it from=20
sin_port/sin6_port, but I agree that SO_PROTOCOL is more generic.

--=20
R=E9mi Denis-Courmont
Nokia Devices R&D, Maemo Software, Helsinki

