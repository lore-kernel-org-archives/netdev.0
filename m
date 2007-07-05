From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH net-2.6.23 take2] UDP: Cleanup UDP encapsulation code
Date: Thu, 05 Jul 2007 18:25:50 +0100
Message-ID: <468D299E.5070902@katalix.com>
References: <200707051618.l65GIh0J030375@quickie.katalix.com> <468D200E.1060200@trash.net> <200707051951.03619@auguste.remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, remi.denis-courmont@nokia.com
To: =?ISO-8859-1?Q?R=E9mi_Denis-Courmont?= <rdenis@simphalempin.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:38103 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758517AbXGERZ4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jul 2007 13:25:56 -0400
In-Reply-To: <200707051951.03619@auguste.remlab.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

R=E9mi Denis-Courmont wrote:

> By the way, couldn't encap_type be remove altogether (using two sligh=
tly=20
> different callbacks for ESP) from udp_sock?

The notion of encap_type is needed for the setsockopt call so it would=20
have to stay in the API. If it were removed from udp_sock, getsockopt=20
would have to derive the encap_type from encap_rcv funcptr values, whic=
h=20
would be messy. I think it might complicate the logic in ESP too.

--=20
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

