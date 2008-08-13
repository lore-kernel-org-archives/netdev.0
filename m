From: gerrit@erg.abdn.ac.uk
Subject: Re: [PATCH] dccp: change L/R must have at least one byte in the
     dccpsf_val field
Date: Wed, 13 Aug 2008 16:04:03 +0100 (BST)
Message-ID: <44269.148.187.160.35.1218639843.squirrel@148.187.160.35>
References: <20080813125532.GD12888@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "David S. Miller" <davem@davemloft.net>,
	"Gerrit Renker" <gerrit@erg.abdn.ac.uk>, netdev@vger.kernel.org,
	dccp@vger.kernel.org
To: "Arnaldo Carvalho de Melo" <acme@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:47198 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752662AbYHMPEa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Aug 2008 11:04:30 -0400
In-Reply-To: <20080813125532.GD12888@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> dccp: change L/R must have at least one byte in the dccpsf_val field
>
> Thanks to Eugene Teo for reporting this problem.
>
> Signed-off-by: Eugene Teo <eugenete@kernel.sg>
> Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Dave, can you please apply -- this patch is for mainline only.

The dccp_setsockopt_change() function has been fully removed in the
test tree (
http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=dccp_exp.git;a=commitdiff;h=f1b8d02c7cb03e22037e1590d04f9ec8ab2423eb),
due to problems it caused.

Will be in contact regarding this soon.

Gerrit



