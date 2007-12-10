From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH 2/8] [TFRC]: Put RX/TX initialisation into tfrc.c
Date: Mon, 10 Dec 2007 10:56:17 +0000
Message-ID: <20071210105617.GA4688@gerrit.erg.abdn.ac.uk>
References: <11971083882331-git-send-email-gerrit@erg.abdn.ac.uk> <11971083881862-git-send-email-gerrit@erg.abdn.ac.uk> <11971083881667-git-send-email-gerrit@erg.abdn.ac.uk> <20071208171317.GC3180@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Arnaldo Carvalho de Melo <acme@redhat.com>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:33031 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751036AbXLJK5F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Dec 2007 05:57:05 -0500
Content-Disposition: inline
In-Reply-To: <20071208171317.GC3180@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| > This separates RX/TX initialisation and puts all packet history / loss intervals
| > initialisation into tfrc.c.
| > The organisation is uniform: slab declaration -> {rx,tx}_init() -> {rx,tx}_exit()
| 
| NAK, you can't call a __exit marked routine from a __init marked
| routine.
| 
Ok thanks, will fix that in revision 2.
