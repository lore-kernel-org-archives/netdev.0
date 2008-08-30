From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH 08/37] dccp: Query supported CCIDs
Date: Sat, 30 Aug 2008 15:52:01 +0200
Message-ID: <20080830135201.GC17190@gerrit.erg.abdn.ac.uk>
References: <1219945512-7723-1-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-2-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-3-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-4-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-5-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-6-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-7-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-8-git-send-email-gerrit@erg.abdn.ac.uk> <1219945512-7723-9-git-send-email-gerrit@erg.abdn.ac.uk> <20080828210031.GO9193@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Arnaldo Carvalho de Melo <acme@redhat.com>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:33698 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751686AbYH3Nwk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Aug 2008 09:52:40 -0400
Content-Disposition: inline
In-Reply-To: <20080828210031.GO9193@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| > This provides a data structure to record which CCIDs are locally supported
| > and three accessor functions:
<snip> 
| But this limits us to the CCIDs at kernel build time, what if I want to
| test CCID4? I guess we could have something like a bitmap and check if
| the bit for that CCID is set, and it would be set at ccid_register time.
| 
| Perhaps using include/linux/bitmap.h :-)
| 
I looked at it and it actually seems an attractive idea. I have the
following suggestion: the key point of this patch set to improve the
present (mainline) interface for feature negotiation.

People have complained earlier about crashes when trying to negotiate
different CCIDs with the present mechanism. I think this happened with D-ITG.

For the present patch set I would like to keep it as it is, since the
existing CCIDs are buggy/incomplete enough to delay work on entirely new
CCIDs.

But the test tree has still empty disk space for lots of patches, so
this is an invitation to contribute.
