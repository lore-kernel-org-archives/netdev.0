From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [RFC] [DCCP]: Deprecate SOCK_DCCP in favour of SOCK_DGRAM
Date: Tue, 13 May 2008 13:23:25 -0300
Message-ID: <20080513162325.GF15306@ghostprotocols.net>
References: <20080513093718.GA24185@gerrit.erg.abdn.ac.uk> <OFDBD6E282.6F00998A-ON88257448.0056D40D-88257448.0057105E@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gerrit Renker <gerrit@erg.abdn.ac.uk>,
	David Miller <davem@davemloft.net>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:39982 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756721AbYEMQYd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 May 2008 12:24:33 -0400
Content-Disposition: inline
In-Reply-To: <OFDBD6E282.6F00998A-ON88257448.0056D40D-88257448.0057105E@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Tue, May 13, 2008 at 08:50:59AM -0700, David Stevens escreveu:
> Are they mutually exclusive?
> 
> Why not add SOCK_DGRAM/IPPROTO_DCCP support while leaving

Because DCCP is not SOCK_DGRAM at all? :)

> the existing stuff alone, and then requiring programs that want to use
> getaddrinfo to use it that way?

I wonder what is the problem with doing what I did when adding support
for DCCP in ttcp, or for AF_LLC in ssh, ncftp, vsftpd, etc, i.e.
getaddrinfo/getnameinfo wrappers that look if SOCK_DCCP or AF_LLC are
being asked for and doing the right thing.

IIRC at the time I asked Ulrich Drepper about adding support for PF_LLC
sockets in glibc and he said that it would be OK as long as it didn't
included PF_LLC sockets in the default search, doing it only when PF_LLC
was explicitely passed. I just never got around to actually cook up the
patches and send it to Uli.

What would be the problem of SOCK_DCCP being handled in glibc in such a
fashion?

- Arnaldo
