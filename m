From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [DCCP] [Announce]: Ack Vector Implementation Notes
Date: Thu, 13 Dec 2007 14:57:02 +0000
Message-ID: <20071213145702.GA18824@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Arnaldo <acme@redhat.com>, dccp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:34401 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755128AbXLMO54 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Dec 2007 09:57:56 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've been working on making DCCP Ack Vectors more robust, dealing more gracefully
with buffer overflow, and fixing two cases which will lead to corrupted buffer state.

The encountered problems and implementation strategy are documented on
	http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/ack_vectors/

I'd be glad for feedback, in particular if there are any errors or points which may have been
overlooked.
