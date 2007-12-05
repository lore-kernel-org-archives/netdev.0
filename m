From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH v2 0/3][BUG-FIX]: Test tree updates and bug fixes
Date: Wed, 5 Dec 2007 12:13:10 -0200
Message-ID: <20071205141310.GF4653@ghostprotocols.net>
References: <11968535863312-git-send-email-gerrit@erg.abdn.ac.uk> <11968535864083-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:57026 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752026AbXLEONO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Dec 2007 09:13:14 -0500
Content-Disposition: inline
In-Reply-To: <11968535864083-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Wed, Dec 05, 2007 at 11:19:44AM +0000, Gerrit Renker escreveu:
> This revision fixes a bug present in the per-socket allocation of RX history 
> entries; identification of this bug is thanks to Arnaldo Carvalho de Melo.
> 
> The bug was in not deallocating history entries when the allocation of 
> one array element failed. The solution in this revised patch set is the
> original one written by Arnaldo.

Ok, this one I posted with some other comments and explanations about
changes other than namespacing, renaming of some functions and removal
of functions not used in this patch.
 
- Arnaldo
