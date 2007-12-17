From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [RFC]: Break up a patch in two (rfc3448bis changes to feedback reception)
Date: Mon, 17 Dec 2007 13:53:49 +0000
Message-ID: <20071217135349.GA5205@gerrit.erg.abdn.ac.uk>
References: <20071217125105.GE5128@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Arnaldo Carvalho de Melo <acme@redhat.com>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:52192 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752480AbXLQNyq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Dec 2007 08:54:46 -0500
Content-Disposition: inline
In-Reply-To: <20071217125105.GE5128@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| 	The end result should be equivalent, but please take a look and
That is a good catch - this patch was a pain to keep updated exactly due
to the many indentation levels. I had a quick look, the patch looks ok.

Just a small suggestion - since the RTT lookup code in tx_packet_recv()
is new, would it make sense to group it with the RTT validation, as e.g.

