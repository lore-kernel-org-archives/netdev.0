From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: Sending complete IPv6 packets without bypassing netfilter/IPsec
Date: Fri, 16 Jan 2009 12:56:15 +0200
Message-ID: <200901161256.15744.remi.denis-courmont@nokia.com>
References: <8CB45DED3262281-2F30-8C9@webmail-stg-d07.sysops.aol.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: "ext jpo234@netscape.net" <jpo234@netscape.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:57682 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761389AbZAPK4c convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2009 05:56:32 -0500
In-Reply-To: <8CB45DED3262281-2F30-8C9@webmail-stg-d07.sysops.aol.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 16 January 2009 12:46:30 ext jpo234@netscape.net, you wrote:
> Herbert,
> sorry for bothering you (and everybody else on the list) again. It
> seems that the stack does not replace a "::" source address with a re=
al
> one when using a PF_INET6/SOCK_RAW/IPPROTO_RAW socket the way it does
> with an IP_HDRINCL IPv4 socket for "0.0.0.0". Do I have to fill this
> one myself

Yes. That's the _whole_ point of writing the header yourself.

> or is there another trick to achieve this?

Use transport-layer raw sockets and let the kernel do the network heade=
r.

--=20
R=E9mi Denis-Courmont
Maemo Software, Nokia Devices R&D

