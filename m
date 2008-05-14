From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [RFC] [DCCP]: Deprecate SOCK_DCCP in favour of SOCK_DGRAM
Date: Wed, 14 May 2008 18:22:04 +0100
Message-ID: <20080514172204.GA1036@gerrit.erg.abdn.ac.uk>
References: <20080513093718.GA24185@gerrit.erg.abdn.ac.uk> <20080513162325.GF15306@ghostprotocols.net> <20080513170325.GB11499@gerrit.erg.abdn.ac.uk> <200805132037.39580.rdenis@simphalempin.com> <4829E87F.1070006@redhat.com> <20080514080942.GB4462@gerrit.erg.abdn.ac.uk> <482AF1DB.1060608@redhat.com> <20080514144518.GA30578@gerrit.erg.abdn.ac.uk> <482B0DF8.9060001@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: R?mi Denis-Courmont <rdenis@simphalempin.com>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	David Stevens <dlstevens@us.ibm.com>,
	David Miller <davem@davemloft.net>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
To: Ulrich Drepper <drepper@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:61312 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755735AbYENRdc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2008 13:33:32 -0400
Content-Disposition: inline
In-Reply-To: <482B0DF8.9060001@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| The question is: is either DCCP or UDPlite important enough to be
| returned in the default list when socktype and protocol are zero?
They are probably both not important enough to be returned in the
default list.

But either is important be considered when a user unambiguously specifies
ai_socktype and/or ai_protocol; to avoid bad/brittle workarounds.
